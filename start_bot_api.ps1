$ConfFile = Join-Path -Path $PSScriptRoot -ChildPath ".conf"

if (-Not (Test-Path -Path $ConfFile)) {
    Write-Host "Error: .conf file not found in $PSScriptRoot." -ForegroundColor Red
    exit
}

$ApiId = ""
$ApiHash = ""

# Parse credentials from .conf
$ConfLines = Get-Content -Path $ConfFile
foreach ($Line in $ConfLines) {
    if ($Line -match "^api_id\s+(.+)") { $ApiId = $matches[1].Trim() }
    if ($Line -match "^api_hash\s+(.+)") { $ApiHash = $matches[1].Trim() }
}

if ([string]::IsNullOrWhiteSpace($ApiId) -or [string]::IsNullOrWhiteSpace($ApiHash)) {
    Write-Host "Error: Could not extract api_id or api_hash from $ConfFile" -ForegroundColor Red
    exit
}

Write-Host "Found API_ID: $ApiId"
Write-Host "Found API_HASH: $ApiHash"
Write-Host "Starting local Telegram Bot API Server..."

# Check if Docker is running
try {
    docker info > $null 2>&1
    if (-Not $?) { throw "Docker daemon not running" }
} catch {
    Write-Host "❌ Error: Docker is not running." -ForegroundColor Red
    Write-Host "Please start Docker Desktop on your Windows machine." -ForegroundColor Red
    exit
}

# Check if the docker container already exists and stop/remove it
$ContainerExists = docker ps -a --format '{{.Names}}' | Select-String -Pattern "^telegram-bot-api$"
if ($ContainerExists) {
    Write-Host "Container 'telegram-bot-api' already exists. Recreating it..."
    docker rm -f telegram-bot-api | Out-Null
}

# Start the Docker container
docker run -d -p 8081:8081 --name telegram-bot-api --restart=always `
  -v telegram-bot-api-data:/var/lib/telegram-bot-api `
  -e TELEGRAM_API_ID="$ApiId" `
  -e TELEGRAM_API_HASH="$ApiHash" `
  aiogram/telegram-bot-api:latest

if ($?) {
    Write-Host "✅ Success! The Telegram Bot API server is now running in the background." -ForegroundColor Green
    Write-Host "   Upload script will automatically connect to it via http://127.0.0.1:8081"
} else {
    Write-Host "❌ Error: Failed to start the Docker container." -ForegroundColor Red
}
