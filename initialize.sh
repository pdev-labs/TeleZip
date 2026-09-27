#!/bin/bash

CONF_FILE=".conf"

echo "================================================"
echo "    Telegram Auto-Zip & Backup Setup Wizard"
echo "================================================"
echo "This script will help you easily configure your"
echo "credentials and automatically generate the .conf file."
echo ""

read -p "Enter your Telegram API ID (from my.telegram.org): " api_id
read -p "Enter your Telegram API Hash: " api_hash
read -p "Enter your App Title (e.g., TG Backup Script): " app_title
read -p "Enter your App Short Name (e.g., tgbackup): " short_name
read -p "Enter your Telegram Bot Token (from @BotFather): " bot_token
read -p "Enter your Target Chat ID (e.g., @mychannel or -100...): " chat_id

# Write to .conf file
echo "api_id $api_id" > "$CONF_FILE"
echo "api_hash $api_hash" >> "$CONF_FILE"
echo "app title $app_title" >> "$CONF_FILE"
echo "short name $short_name" >> "$CONF_FILE"
echo "bot_token $bot_token" >> "$CONF_FILE"
echo "chat_id $chat_id" >> "$CONF_FILE"

echo ""
echo "================================================"
echo "✅ Setup Complete! Configuration saved to .conf"
echo "================================================"
echo "Your toolkit is fully configured. Workflow:"
echo "  1. ./auto_zip.sh         -> Compress your folders"
echo "  2. ./start_bot_api.sh    -> Start the 2GB upload server"
echo "  3. ./upload_telegram.sh  -> Upload everything to Telegram"
echo ""
