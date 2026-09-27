#!/bin/bash

# Read Bot Token and Chat ID from .conf if they exist
CONF_FILE="/home/pdev/hdd/auto-zip/.conf"
BOT_TOKEN=$(awk '/^bot_token/ {print $2}' "$CONF_FILE" 2>/dev/null)
CHAT_ID=$(awk '/^chat_id/ {print $2}' "$CONF_FILE" 2>/dev/null)

API_URL="http://127.0.0.1:8081" # Local Telegram API Server URL

# Check for curl
if ! command -v curl &> /dev/null; then
    echo "Error: 'curl' is required to upload files."
    echo "Please install it using your package manager (e.g., apt install curl, pkg install curl)."
    exit 1
fi

# Prompt for credentials if not hardcoded
if [ -z "$BOT_TOKEN" ]; then
    read -p "Enter your Telegram Bot Token: " BOT_TOKEN
fi

if [ -z "$CHAT_ID" ]; then
    read -p "Enter the Chat ID (channel username like @mychannel, or numeric Contact ID): " CHAT_ID
fi

# Auto-detect zip folder ending in '-zip' in the current directory
auto_detected=$(find . -maxdepth 1 -type d -name "*-zip" | head -n 1)

if [ -n "$auto_detected" ] && [ -d "$auto_detected" ]; then
    suggested_dir=$(realpath "$auto_detected")
    read -p "🔍 I have found the folder '$suggested_dir'. Should I start uploading? (y/N): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        zip_dir="$suggested_dir"
    fi
fi

if [ -z "$zip_dir" ]; then
    # Prompt for the directory containing the zip files
    read -e -p "Enter the path of the folder containing the zip files: " zip_dir

    # Resolve path
    zip_dir=$(eval echo "$zip_dir")
    if [ ! -d "$zip_dir" ]; then
        echo "Error: Directory '$zip_dir' does not exist."
        exit 1
    fi
fi

count=0

# Loop through all zip files in the directory
shopt -s nullglob
for zip_file in "$zip_dir"/*.zip; do
    filename=$(basename "$zip_file")
    
    # Calculate file size in MB
    if command -v stat &> /dev/null; then
        # Check OS for stat syntax
        if stat -c %s "$zip_file" &> /dev/null; then
            size_bytes=$(stat -c %s "$zip_file")
        else
            size_bytes=$(stat -f %z "$zip_file")
        fi
        size_mb=$((size_bytes / 1024 / 1024))
        
        # Local Telegram Bot API limit is 2000MB (2GB) for bots.
        if [ "$size_mb" -ge 2000 ]; then
            echo "Warning: '$filename' is ${size_mb}MB. Even with a local API server, files cannot exceed 2000MB."
            echo "Skipping $filename..."
            echo "----------------------------------------"
            continue
        fi
    fi

    echo "Uploading '$filename'..."
    
    # Upload via Telegram Bot API using curl with a progress bar
    response=$(curl -# -w "\n%{http_code}" -X POST \
        "${API_URL}/bot${BOT_TOKEN}/sendDocument" \
        -F chat_id="${CHAT_ID}" \
        -F document=@"${zip_file}")
    
    # Extract the HTTP status code (the last line of the curl output)
    http_code=$(echo "$response" | tail -n1)
    
    if [ "$http_code" -eq 200 ]; then
        echo "✅ Successfully uploaded $filename."
        count=$((count + 1))
    else
        echo "❌ Failed to upload $filename."
        echo "HTTP Status Code: $http_code"
        echo "Response from Telegram: $(echo "$response" | head -n -1)"
    fi
    echo "----------------------------------------"
done

if [ $count -eq 0 ]; then
    echo "No valid .zip files were uploaded."
else
    echo "Done! Uploaded $count files to Telegram."
fi
