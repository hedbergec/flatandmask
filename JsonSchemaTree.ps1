Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# -----------------------------
# Schema collection (for file output)
# -----------------------------
$global:TreeLines = New-Object System.Collections.Generic.List[string]

function Add-TreeLine {
    param([string]$line)
    $global:TreeLines.Add($line) | Out-Null
}

# -----------------------------
# Recursive schema printer
# -----------------------------
function Show-TreeFromJson {
    param(
        [object]$Object,
        [string]$Prefix = ""
    )

    if ($Object -is [System.Collections.IDictionary] -or $Object -is [PSCustomObject]) {

        foreach ($prop in $Object.PSObject.Properties) {
            $newPrefix = if ($Prefix) { "$Prefix.$($prop.Name)" } else { $prop.Name }
            Show-TreeFromJson -Object $prop.Value -Prefix $newPrefix
        }
    }
    elseif ($Object -is [System.Collections.IEnumerable] -and -not ($Object -is [string])) {

        $arrayPath = "$Prefix[]"

        Write-Host $arrayPath
        Add-TreeLine $arrayPath

        $first = $Object | Select-Object -First 1
        if ($first) {
            Show-TreeFromJson -Object $first -Prefix $arrayPath
        }
    }
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
# Button click logic
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

            $global:TreeLines.Add("root") | Out-Null
            Write-Host "root"

            if ($json -is [System.Collections.IEnumerable] -and -not ($json -is [string])) {
                $global:TreeLines.Add("root[]") | Out-Null
                Write-Host "root[]"

                $first = $json | Select-Object -First 1
                if ($first) {
                    Show-TreeFromJson -Object $first -Prefix "root[]"
                }
            }
            else {
                Show-TreeFromJson -Object $json -Prefix "root"
            }

            # -----------------------------
            # EXPORT tree.txt next to JSON
            # -----------------------------
            $outPath = Join-Path (Split-Path $dialog.FileName) "tree.txt"

            $global:TreeLines | Set-Content -Path $outPath -Encoding UTF8

            Write-Host "`n===================================="
            Write-Host "Saved schema tree to:"
            Write-Host $outPath
            Write-Host "===================================="

        }
        catch {
            Write-Host "ERROR: Invalid JSON or unreadable file."
        }
    }
})

$form.ShowDialog()