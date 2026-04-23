Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# -----------------------------
# Global storage for export
# -----------------------------
$global:TreeLines = New-Object System.Collections.Generic.List[string]

function Add-TreeLine {
    param([string]$line)
    $global:TreeLines.Add($line) | Out-Null
}

# -----------------------------
# Core schema tree traversal
# -----------------------------
function Show-TreeFromJson {
    param(
        [object]$Object,
        [string]$Prefix = ""
    )

    # -------------------------
    # Object (dictionary / PSObject)
    # -------------------------
    if ($Object -is [System.Collections.IDictionary] -or $Object -is [PSCustomObject]) {

        foreach ($prop in $Object.PSObject.Properties) {

            $name = $prop.Name
            $value = $prop.Value

            $newPrefix = if ($Prefix) { "$Prefix.$name" } else { $name }

            Show-TreeFromJson -Object $value -Prefix $newPrefix
        }
    }

    # -------------------------
    # Array handling
    # -------------------------
    elseif ($Object -is [System.Collections.IEnumerable] -and -not ($Object -is [string])) {

        # Print array node (structural marker only)
        if ($Prefix) {
            Write-Host "$Prefix[]"
            Add-TreeLine "$Prefix[]"
        }

        # Inspect first element only (schema inference)
        $first = $Object | Select-Object -First 1

        if ($first) {
            # IMPORTANT: do NOT append [] to prefix for children
            Show-TreeFromJson -Object $first -Prefix $Prefix
        }
    }

    # -------------------------
    # Leaf node (primitive)
    # -------------------------
    else {
        if ($Prefix) {
            Write-Host $Prefix
            Add-TreeLine $Prefix
        }
    }
}

# -----------------------------
# GUI Window
# -----------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "JSON Schema Tree Viewer"
$form.Size = New-Object System.Drawing.Size(420,160)
$form.StartPosition = "CenterScreen"

$button = New-Object System.Windows.Forms.Button
$button.Text = "Select JSON File"
$button.Width = 160
$button.Height = 40
$button.Top = 40
$button.Left = 120

$form.Controls.Add($button)

# -----------------------------
# Button click handler
# -----------------------------
$button.Add_Click({

    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "JSON files (*.json)|*.json|All files (*.*)|*.*"

    if ($dialog.ShowDialog() -eq "OK") {

        Clear-Host
        $global:TreeLines.Clear()

        Write-Host "===================================="
        Write-Host "JSON Schema Tree"
        Write-Host "File: $($dialog.FileName)"
        Write-Host "====================================`n"

        try {
            $json = Get-Content $dialog.FileName -Raw | ConvertFrom-Json

            # Root
            Write-Host "root"
            Add-TreeLine "root"

            # Array root case
            if ($json -is [System.Collections.IEnumerable] -and -not ($json -is [string])) {

                Write-Host "root[]"
                Add-TreeLine "root[]"

                $first = $json | Select-Object -First 1
                if ($first) {
                    Show-TreeFromJson -Object $first -Prefix "root"
                }
            }
            else {
                Show-TreeFromJson -Object $json -Prefix "root"
            }

            # -----------------------------
            # Export tree.txt next to JSON
            # -----------------------------
            $outPath = Join-Path (Split-Path $dialog.FileName) "tree.txt"

            $global:TreeLines | Set-Content -Path $outPath -Encoding UTF8

            Write-Host "`n===================================="
            Write-Host "Exported schema tree to:"
            Write-Host $outPath
            Write-Host "===================================="

        }
        catch {
            Write-Host "ERROR: Invalid JSON or file could not be parsed."
        }
    }
})

# -----------------------------
# Run GUI
# -----------------------------
$form.ShowDialog()
