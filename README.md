# 📦 TeleZip

A highly efficient, cross-platform toolkit that automatically compresses subfolders and uploads them directly to a Telegram channel or chat. By leveraging a local Dockerized Telegram Bot API server, this toolkit **bypasses the standard 50MB bot upload limit**, allowing you to seamlessly upload files up to **2GB** each!

## ✨ New in TeleZip AIO (All-In-One)
The new `telezip_aio.py` unifies all scripts into one incredibly powerful application with advanced features:
- **🚄 Parallel Processing**: Zips multiple folders and uploads multiple files concurrently.
- **💾 Pause & Resume**: Saves state automatically. If your internet cuts out, run it again and it skips what's already uploaded.
- **🗑️ Auto-Cleanup**: Optionally deletes local zip files immediately after a successful upload to save disk space.
- **🚫 Smart Exclusions**: Skip unnecessary folders (like `node_modules` or `.git`) on the fly.
- **🔒 Password Encryption**: Securely lock your zip files with an AES password before uploading.
- **📝 Automatic Captions & Notifications**: Adds beautiful captions to your uploads and sends a final text summary when the entire backup is complete!

## 🌍 Legacy Support
We still provide native `.sh` scripts for Linux/macOS/Termux and `.ps1` scripts for Windows PowerShell if you prefer individual lightweight tools without needing Python.

---

## 📋 Prerequisites

1. **Python 3**: Required to run the AIO master script.
2. **Docker**: Required to run the local Telegram API Server (for 2GB uploads).
3. **Telegram API ID & Hash**: Get this for free from [my.telegram.org](https://my.telegram.org/).
4. **Telegram Bot Token**: Get this from [@BotFather](https://t.me/BotFather).

---

## 🛠️ Installation & Usage

1. **Download or Clone the Toolkit:**
   **Option A: Zip Download (Recommended)**
   Head to the [Releases](https://github.com/pdev-labs/TeleZip/releases/latest) page and download `TeleZip-AIO.zip` (or the legacy packages for your system).
   
   **Option B: Git Clone**
   ```bash
   git clone https://github.com/pdev-labs/TeleZip.git
   cd TeleZip
   ```
   
2. **Run the Initialization Wizard:**
   Run the setup wizard to securely save your API keys in a local `.conf` file:
   - Linux/Mac: `./initialize.sh`
   - Windows: `.\initialize.ps1`

3. **Start the Local API Server:**
   You must start the 2GB upload server before running the AIO script:
   - Linux/Mac: `./start_bot_api.sh`
   - Windows: `.\start_bot_api.ps1`

4. **Run the AIO Backup:**
   Launch the master script and follow the on-screen prompts to parallel zip, encrypt, and upload your entire directory automatically!
   ```bash
   python3 telezip_aio.py
   ```

---

## 📄 License
This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
