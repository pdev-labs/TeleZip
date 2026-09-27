$ConfFile = Join-Path -Path $PSScriptRoot -ChildPath ".conf"

$BotToken = ""
$ChatId = ""
$ApiUrl = "http://127.0.0.1:8081"

# Read .conf if exists
if (Test-Path -Path $ConfFile) {
    $ConfLines = Get-Content -Path $ConfFile
    foreach ($Line in $ConfLines) {
        if ($Line -match "^bot_token\s+(.+)") { $BotToken = $matches[1].Trim() }
        if ($Line -match "^chat_id\s+(.+)") { $ChatId = $matches[1].Trim() }
    }
}

if ([string]::IsNullOrWhiteSpace($BotToken)) {
    $BotToken = Read-Host "Enter your Telegram Bot Token"
}
if ([string]::IsNullOrWhiteSpace($ChatId)) {
    $ChatId = Read-Host "Enter the Chat ID (channel username or numeric Contact ID)"
}

$ZipDir = ""
$AutoDetect = Get-ChildItem -Path . -Directory -Filter "*-zip" | Select-Object -First 1

if ($AutoDetect) {
    $SuggestedDir = $AutoDetect.FullName
    $Choice = Read-Host "🔍 I have found the folder '$SuggestedDir'. Should I start uploading? (y/N)"
    if ($Choice -match "^[Yy]$") {
        $ZipDir = $SuggestedDir
    }
}

if ([string]::IsNullOrWhiteSpace($ZipDir)) {
    $ZipDir = Read-Host "Enter the path of the folder containing the zip files"
}

if (-Not (Test-Path -Path $ZipDir -PathType Container)) {
    Write-Host "Error: Directory '$ZipDir' does not exist." -ForegroundColor Red
    exit
}

$ZipFiles = Get-ChildItem -Path $ZipDir -Filter "*.zip"

$Count = 0
foreach ($File in $ZipFiles) {
    $SizeMB = [math]::Round($File.Length / 1MB, 2)
    
    if ($SizeMB -ge 2000) {
        Write-Host "Warning: '$($File.Name)' is ${SizeMB}MB. Files cannot exceed 2000MB." -ForegroundColor Yellow
        continue
    }

    Write-Host "Uploading '$($File.Name)'..."
    
    $Uri = "$ApiUrl/bot$BotToken/sendDocument?chat_id=$ChatId"
    
    try {
        # PowerShell Invoke-WebRequest to upload file securely and display progress
        $Response = Invoke-WebRequest -Uri $Uri -Method Post -Form @{
            document = Get-Item -Path $File.FullName
        }
        if ($Response.StatusCode -eq 200) {
            Write-Host "✅ Successfully uploaded $($File.Name)." -ForegroundColor Green
            $Count++
        }
    } catch {
        Write-Host "❌ Failed to upload $($File.Name)." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

if ($Count -eq 0) {
    Write-Host "No valid .zip files were uploaded." -ForegroundColor Yellow
} else {
    Write-Host "Done! Uploaded $Count files to Telegram." -ForegroundColor Green
}
