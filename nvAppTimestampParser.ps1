Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Normalize-Path {
    param ($rawPath)
    $path = $rawPath -replace '\s{2,}', ' '
    $path = $path.Trim()
    $path = $path -replace '/', '\'
    $path = $path -replace '^([a-zA-Z])\\', '$1:\'
    $path = $path -replace '(?i)programfiles\(x86\)', 'Program Files (x86)'
    $path = $path -replace '(?i)programfiles', 'Program Files'
    $path = $path -replace '(?i)windows', 'Windows'
    if ($path -notmatch '\.exe$') {
        $path = $path -replace '\. ?e ?x ?e$', '.exe'
    }
    return $path
}

function Test-FileExistence {
    param ($path)
    try {
        if (Test-Path $path -PathType Leaf) {
            return "Exists"
        } else {
            return "Deleted"
        }
    } catch {
        return "Error Checking"
    }
}

function Test-CodeSignature {
    param ($file)
    try {
        $signature = Get-AuthenticodeSignature -FilePath $file -ErrorAction Stop
        if ($signature.Status -eq 'Valid') {
            return "Signed"
        } else {
            return "Not Signed"
        }
    } catch {
        return "N/A"
    }
}

function ApplyFilters {
    $filterText = $searchBox.Text.ToLower()
    $anyFilterSelected = $checkboxDeleted.Checked -or $checkboxUnsigned.Checked -or $checkboxInInstance.Checked
    foreach ($row in $grid.Rows) {
        $path = $row.Cells["Path"].Value.ToLower()
        $fileStatus = $row.Cells["Status"].Value
        $signatureStatus = $row.Cells["Signature"].Value
        $matchesSearch = $path -like "*$filterText*"
        if (-not $anyFilterSelected) {
            $row.Visible = $matchesSearch
        } else {
            $matchesFilter = $false
            if ($checkboxDeleted.Checked -and $fileStatus -eq "Deleted") {
                $matchesFilter = $true
            } elseif ($checkboxUnsigned.Checked -and $signatureStatus -eq "Not Signed") {
                $matchesFilter = $true
            } elseif ($checkboxInInstance.Checked -and $fileStatus -eq "Exists") {
                $matchesFilter = $true
            }
            $row.Visible = $matchesSearch -and $matchesFilter
        }
    }
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "nvAppTimestamp Parser"
$form.Size = New-Object System.Drawing.Size(1100, 700)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.ForeColor = [System.Drawing.Color]::White
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$headerLabel = New-Object System.Windows.Forms.Label
$headerLabel.Text = "nvAppTimestamp Parser"
$headerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$headerLabel.AutoSize = $true
$headerLabel.Location = New-Object System.Drawing.Point(10, 18)
$headerLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
$headerLabel.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($headerLabel)

$searchLabel = New-Object System.Windows.Forms.Label
$searchLabel.Text = "Search:"
$searchLabel.Location = New-Object System.Drawing.Point(500, 45)
$searchLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$searchLabel.ForeColor = [System.Drawing.Color]::White
$searchLabel.AutoSize = $true
$form.Controls.Add($searchLabel)

$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Location = New-Object System.Drawing.Point(560, 45)
$searchBox.Width = 200
$searchBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$searchBox.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
$searchBox.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($searchBox)

$checkboxDeleted = New-Object System.Windows.Forms.CheckBox
$checkboxDeleted.Text = "Deleted"
$checkboxDeleted.Location = New-Object System.Drawing.Point(770, 45)
$checkboxDeleted.AutoSize = $true
$checkboxDeleted.ForeColor = [System.Drawing.Color]::White
$checkboxDeleted.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$checkboxDeleted.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$checkboxDeleted.Checked = $false
$checkboxDeleted.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($checkboxDeleted)

$checkboxUnsigned = New-Object System.Windows.Forms.CheckBox
$checkboxUnsigned.Text = "Unsigned"
$checkboxUnsigned.Location = New-Object System.Drawing.Point(870, 45)
$checkboxUnsigned.AutoSize = $true
$checkboxUnsigned.ForeColor = [System.Drawing.Color]::White
$checkboxUnsigned.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$checkboxUnsigned.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$checkboxUnsigned.Checked = $false
$checkboxUnsigned.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($checkboxUnsigned)

$checkboxInInstance = New-Object System.Windows.Forms.CheckBox
$checkboxInInstance.Text = "In Instance"
$checkboxInInstance.Location = New-Object System.Drawing.Point(970, 45)
$checkboxInInstance.AutoSize = $true
$checkboxInInstance.ForeColor = [System.Drawing.Color]::White
$checkboxInInstance.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$checkboxInInstance.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$checkboxInInstance.Checked = $false
$checkboxInInstance.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($checkboxInInstance)

$grid = New-Object System.Windows.Forms.DataGridView
$grid.Location = New-Object System.Drawing.Point(10, 70)
$grid.Size = New-Object System.Drawing.Size(1070, 540)
$grid.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$grid.ReadOnly = $true
$grid.AllowUserToAddRows = $false
$grid.AllowUserToResizeRows = $false
$grid.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::None
$grid.BackgroundColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
$grid.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
$grid.DefaultCellStyle.ForeColor = [System.Drawing.Color]::White
$grid.AlternatingRowsDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(37, 37, 38)
$grid.AlternatingRowsDefaultCellStyle.ForeColor = [System.Drawing.Color]::White
$grid.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 28)
$grid.ColumnHeadersDefaultCellStyle.ForeColor = [System.Drawing.Color]::White
$grid.GridColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$grid.RowHeadersVisible = $false
$grid.RowTemplate.Height = 25

$grid.Columns.Add("Path", "File Path") | Out-Null
$grid.Columns.Add("Signature", "Signature Status") | Out-Null
$grid.Columns.Add("Status", "File Status") | Out-Null

$grid.Columns["Path"].AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::Fill
$grid.Columns["Signature"].AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::AllCells
$grid.Columns["Status"].AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::AllCells

$form.Controls.Add($grid)

$statusBar = New-Object System.Windows.Forms.Label
$statusBar.Dock = 'Bottom'
$statusBar.TextAlign = 'MiddleLeft'
$statusBar.Height = 30
$statusBar.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$statusBar.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$statusBar.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($statusBar)

$form.Add_Load({
    Write-Progress -Activity "Processing nvAppTimestamps" -Status "Initializing" -PercentComplete 0
    $drsPath = "C:\ProgramData\NVIDIA Corporation\Drs"
    $fileName = "nvAppTimestamps"
    $filePath = Join-Path $drsPath $fileName
    $outputPath = "$PSScriptRoot\nvAppTimestampParsed.txt"
    if (Test-Path $filePath) {
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        Write-Progress -Activity "Processing nvAppTimestamps" -Status "File read" -PercentComplete 10
        $decoded1 = [System.Text.Encoding]::ASCII.GetString($bytes)
        $decoded2 = [System.Text.Encoding]::Unicode.GetString($bytes)
        $combinedText = "$decoded1 `n $decoded2"
        $pattern = "(?:[a-zA-Z] ?[:：] ?[\\/])(?:[a-zA-Z0-9_\-\.\(\)% ]{2,}[\\/])+[a-zA-Z0-9_\-\.\(\)% ]+\. ?e ?x ?e"
        $matches = [regex]::Matches($combinedText, $pattern)
        Write-Progress -Activity "Processing nvAppTimestamps" -Status "Matches extracted" -PercentComplete 20
        $results = @()
        foreach ($match in $matches) {
            $raw = $match.Value
            $cleaned = Normalize-Path $raw
            $results += $cleaned
        }
        $results = $results | Sort-Object -Unique
        $detailedOutput = @()
        for ($i = 0; $i -lt $results.Count; $i++) {
            $exe = $results[$i]
            $fileStatus = Test-FileExistence $exe
            $sigStatus = if ($fileStatus -eq "Exists") { Test-CodeSignature $exe } else { "N/A" }
            $grid.Rows.Add($exe, $sigStatus, $fileStatus) | Out-Null
            $detailedOutput += "$exe`t$sigStatus`t$fileStatus"
            $percentComplete = 20 + [Math]::Floor(70 * ($i + 1) / $results.Count)
            Write-Progress -Activity "Processing nvAppTimestamps" -Status "Processing path $($i + 1) of $($results.Count)" -PercentComplete $percentComplete
        }
        ApplyFilters
        $detailedOutput | Out-File -FilePath $outputPath -Encoding UTF8
        Write-Progress -Activity "Processing nvAppTimestamps" -Status "Saving output" -PercentComplete 90
        $statusBar.Text = "✅ Total scanned: $($results.Count) | Output: $outputPath"
        Write-Progress -Activity "Processing nvAppTimestamps" -Status "Complete" -PercentComplete 100
        Start-Sleep -Milliseconds 500
        Write-Progress -Activity "Processing nvAppTimestamps" -Completed
    } else {
        [System.Windows.Forms.MessageBox]::Show("❌ File not found: $filePath", "Error", "OK", "Error")
    }
})

$searchBox.Add_TextChanged({
    ApplyFilters
})

$checkboxDeleted.Add_CheckedChanged({
    if ($checkboxDeleted.Checked) {
        $checkboxUnsigned.Checked = $false
        $checkboxInInstance.Checked = $false
    }
    ApplyFilters
})

$checkboxUnsigned.Add_CheckedChanged({
    if ($checkboxUnsigned.Checked) {
        $checkboxDeleted.Checked = $false
        $checkboxInInstance.Checked = $false
    }
    ApplyFilters
})

$checkboxInInstance.Add_CheckedChanged({
    if ($checkboxInInstance.Checked) {
        $checkboxDeleted.Checked = $false
        $checkboxUnsigned.Checked = $false
    }
    ApplyFilters
})

$grid.add_CellFormatting({
    param($sender, $e)
    if ($e.ColumnIndex -eq $grid.Columns["Signature"].Index) {
        $value = $e.Value
        if ($value -eq "Not Signed") {
            $e.CellStyle.ForeColor = [System.Drawing.Color]::Red
        } elseif ($value -eq "Signed") {
            $e.CellStyle.ForeColor = [System.Drawing.Color]::Green
        } else {
            $e.CellStyle.ForeColor = [System.Drawing.Color]::White
        }
    } elseif ($e.ColumnIndex -eq $grid.Columns["Status"].Index) {
        $value = $e.Value
        if ($value -eq "Deleted") {
            $e.CellStyle.ForeColor = [System.Drawing.Color]::Red
        } elseif ($value -eq "Exists") {
            $e.CellStyle.ForeColor = [System.Drawing.Color]::Green
        } else {
            $e.CellStyle.ForeColor = [System.Drawing.Color]::White
        }
    }
})

[void]$form.ShowDialog()