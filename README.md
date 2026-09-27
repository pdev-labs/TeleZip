# 📦 TeleZip

A highly efficient, cross-platform toolkit that automatically compresses subfolders and uploads them directly to a Telegram channel or chat. By leveraging a local Dockerized Telegram Bot API server, this toolkit **bypasses the standard 50MB bot upload limit**, allowing you to seamlessly upload files up to **2GB** each!

## ✨ Features
- **🌍 100% Cross-Platform**: Includes native `.sh` scripts for Linux, macOS, and Android (via Termux), and native `.ps1` scripts for Windows PowerShell.
- **🚀 2GB Upload Limit**: Automatically spins up a local Telegram API server via Docker to handle massive files natively.
- **🪄 Setup Wizard**: An interactive `initialize` script sets up all your API keys and tokens in seconds so you never have to mess with config files manually.
- **🤖 Auto-Detection**: Automatically detects newly generated zip folders and seamlessly queues them for upload with a confirmation prompt.
- **📊 Live Progress Bar**: View real-time upload speeds and progress bars directly in your terminal.
- **⚡ Dependency Auto-Installer**: Bash scripts will automatically install `zip` or `curl` via your package manager if they are missing.

---

## 📋 Prerequisites

1. **Docker / Docker Desktop**: Required to run the local Telegram API Server (for 2GB uploads).
2. **Telegram API ID & Hash**: Get this for free from [my.telegram.org](https://my.telegram.org/).
3. **Telegram Bot Token**: Get this from [@BotFather](https://t.me/BotFather) on Telegram.
4. **Target Chat ID**: The `@username` of your channel or the numeric ID of your group.

---

## 🛠️ Installation & Setup

1. **Download the Toolkit:**
   Head to the [Releases](https://github.com/pdev-labs/TeleZip/releases/latest) page and download the zip file for your system:
   - 🐧/🍏 **TeleZip-Unix.zip** (Linux, macOS, Android/Termux)
   - 🪟 **TeleZip-Windows.zip** (Windows)
   
   Extract the zip file and open your terminal inside the extracted folder.
   
   *(Alternatively, you can `git clone https://github.com/pdev-labs/TeleZip.git`)*

2. **Run the Initialization Wizard:**
   This wizard will ask for your Telegram credentials and safely store them in a local `.conf` file.
   - **Linux / macOS / Termux:**
     ```bash
     chmod +x *.sh
     ./initialize.sh
     ```
   - **Windows:**
     ```powershell
     .\initialize.ps1
     ```
   *(Note: The `.conf` file is ignored by git to protect your secrets).*

---

## 🚀 Usage Workflow

Using the toolkit is a simple 3-step process. 

### Step 1: Compress Your Folders
Run the zip script. It will ask for a parent directory, and it will zip every subfolder inside it individually.
- **Linux/Mac**: `./auto_zip.sh`
- **Windows**: `.\auto_zip.ps1`

### Step 2: Start the Local API Server
Start the Dockerized Telegram API server in the background to unlock 2GB uploads.
- **Linux/Mac**: `./start_bot_api.sh`
- **Windows**: `.\start_bot_api.ps1`

### Step 3: Upload to Telegram
Run the upload script. It will automatically detect your newly zipped folder and begin pushing the files to your Telegram chat with a live progress bar!
- **Linux/Mac**: `./upload_telegram.sh`
- **Windows**: `.\upload_telegram.ps1`

---

## 🔒 Security
**Never commit your `.conf` file to a public repository!** 
This repository includes a `.gitignore` specifically designed to prevent `.conf` from being tracked by git, keeping your API tokens and keys completely safe on your local machine.

## 📄 License
This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
