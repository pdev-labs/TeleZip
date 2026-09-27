$ConfFile = Join-Path -Path $PSScriptRoot -ChildPath ".conf"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "    Telegram Auto-Zip & Backup Setup Wizard" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "This script will help you easily configure your"
Write-Host "credentials and automatically generate the .conf file."
Write-Host ""

$ApiId = Read-Host "Enter your Telegram API ID (from my.telegram.org)"
$ApiHash = Read-Host "Enter your Telegram API Hash"
$AppTitle = Read-Host "Enter your App Title (e.g., TG Backup Script)"
$ShortName = Read-Host "Enter your App Short Name (e.g., tgbackup)"
$BotToken = Read-Host "Enter your Telegram Bot Token (from @BotFather)"
$ChatId = Read-Host "Enter your Target Chat ID (e.g., @mychannel or -100...)"

$ConfContent = @"
api_id $ApiId
api_hash $ApiHash
app title $AppTitle
short name $ShortName
bot_token $BotToken
chat_id $ChatId
"@

Set-Content -Path $ConfFile -Value $ConfContent -Encoding UTF8

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "✅ Setup Complete! Configuration saved to .conf" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Your toolkit is fully configured. Workflow:" -ForegroundColor Yellow
Write-Host "  1. .\auto_zip.ps1         -> Compress your folders" -ForegroundColor Yellow
Write-Host "  2. .\start_bot_api.ps1    -> Start the 2GB upload server" -ForegroundColor Yellow
Write-Host "  3. .\upload_telegram.ps1  -> Upload everything to Telegram" -ForegroundColor Yellow
Write-Host ""
