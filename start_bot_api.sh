#!/bin/bash

CONF_FILE=".conf"

# Check if the .conf file exists
if [ ! -f "$CONF_FILE" ]; then
    # Try the absolute path just in case the script is run from outside the directory
    CONF_FILE="/home/pdev/hdd/auto-zip/.conf"
    if [ ! -f "$CONF_FILE" ]; then
        echo "Error: .conf file not found."
        exit 1
    fi
fi

# Extract api_id and api_hash using awk
API_ID=$(awk '/^api_id/ {print $2}' "$CONF_FILE")
API_HASH=$(awk '/^api_hash/ {print $2}' "$CONF_FILE")

if [ -z "$API_ID" ] || [ -z "$API_HASH" ]; then
    echo "Error: Could not extract api_id or api_hash from $CONF_FILE"
    exit 1
fi

echo "Found API_ID: $API_ID"
echo "Found API_HASH: $API_HASH"
echo "Starting local Telegram Bot API Server..."

# Check if Docker is running
if ! sudo docker info &> /dev/null; then
    echo "❌ Error: Docker is not running or you don't have permissions."
    echo "Please start Docker. On Arch Linux you can run:"
    echo "  sudo systemctl start docker"
    echo "  sudo systemctl enable docker"
    exit 1
fi

# Check if the docker container already exists and stop/remove it
if sudo docker ps -a --format '{{.Names}}' | grep -Eq "^telegram-bot-api$"; then
    echo "Container 'telegram-bot-api' already exists. Recreating it..."
    sudo docker rm -f telegram-bot-api
fi

# Run the docker command using the parsed credentials
sudo docker run -d -p 8081:8081 --name telegram-bot-api --restart=always \
  -v telegram-bot-api-data:/var/lib/telegram-bot-api \
  -e TELEGRAM_API_ID="$API_ID" \
  -e TELEGRAM_API_HASH="$API_HASH" \
  aiogram/telegram-bot-api:latest

if [ $? -eq 0 ]; then
    echo "✅ Success! The Telegram Bot API server is now running in the background."
    echo "   Upload script will automatically connect to it via http://127.0.0.1:8081"
else
    echo "❌ Error: Failed to start the Docker container. Make sure Docker is installed and running."
fi
