# 📦 TeleZip

[![GitHub release](https://img.shields.io/github/v/release/pdev-labs/TeleZip)](https://github.com/pdev-labs/TeleZip/releases/latest)
[![CI](https://github.com/pdev-labs/TeleZip/actions/workflows/ci.yml/badge.svg)](https://github.com/pdev-labs/TeleZip/actions/workflows/ci.yml)
[![License: GPL-3.0](https://img.shields.io/github/license/pdev-labs/TeleZip)](LICENSE)

A cross-platform toolkit that compresses each subfolder of a parent directory into its own `.zip` and uploads the zips to a Telegram channel or chat.

Telegram's public Bot API caps bot uploads at **50 MB**. TeleZip runs a **local Telegram Bot API server in Docker**, which raises the per-file limit to **2 GB**, and uploads through it — so large backups go through as normal `sendDocument` calls.

Two ways to use it:

| Path | Tool | Best for |
|---|---|---|
| **AIO (recommended)** | `python3 telezip_aio.py` | One command: parallel zip + parallel upload, resume, exclusions, password, auto-cleanup, summary message |
| **Legacy step-by-step** | `.sh` (Linux/macOS/Termux) / `.ps1` (Windows) scripts | No Python, or you want to run each stage manually |

No `pip install` needed — the Python script uses only the standard library plus the external `zip`, `curl`, and `docker` CLIs.

---

## ✨ Features

### AIO (`telezip_aio.py`)
- **🚄 Parallel zipping** — up to 4 folders at once (`ThreadPoolExecutor(max_workers=4)`).
- **🚀 Parallel uploads** — up to 3 files at once (`max_workers=3`) via `curl` subprocesses.
- **💾 Pause & resume** — every successful upload is appended to `.telezip_state.json` in the current directory. Re-run and already-uploaded zips are skipped (`⏩ Skipping …`). Delete that file to force a full re-upload.
- **🗑️ Auto-cleanup** — optionally deletes each local `.zip` right after its upload succeeds.
- **🚫 Smart exclusions** — comma-separated patterns (e.g. `node_modules,.git`) passed to `zip -x` as `*pattern*`.
- **🔒 Password encryption** — optional `zip -r -P <password>` encryption per archive.
- **📝 Captions & summary** — each document gets a caption (`📁 Folder / 💾 Size / ⚡ Powered by TeleZip AIO`), and a final `sendMessage` reports files uploaded, total MB, and elapsed seconds.

### Legacy scripts
- `auto_zip` — zips every immediate subfolder of a parent dir into `<parent>/<parent>-zip/<sub>.zip` (skips the output dir itself). The `.sh` version auto-installs `zip` via `pkg`/`apt`/`brew`/`pacman`/`dnf`/`yum` if missing; the `.ps1` version uses built-in `Compress-Archive`.
- `upload_telegram` — uploads every `*.zip` in a folder with a progress display, skipping files ≥ 2000 MB. Auto-detects a `*-zip` folder in the current directory and asks to use it before prompting for a path.

---

## 📋 Prerequisites

1. **Python 3** — only for the AIO script. Check with `python3 --version`.
2. **`zip` and `curl`** — used by both AIO and legacy scripts. (`auto_zip.sh` installs `zip` for you; `upload` scripts abort with install instructions if `curl` is missing.)
3. **Docker** — running daemon, for the local Bot API server. Linux: `sudo systemctl start docker`. Windows/macOS: start Docker Desktop.
4. **Telegram API ID + API Hash** — free from [my.telegram.org](https://my.telegram.org/) (needed by the local API server, not by Telegram's public endpoint).
5. **Bot token** — from [@BotFather](https://t.me/BotFather).
6. **Target chat ID** — channel/group numeric ID (e.g. `-100…`) or `@channelusername`. The bot must be a member/admin of the target with permission to post documents.

---

## 🛠️ Installation

**Option A — Release zip (recommended for non-developers)**
Download `TeleZip-AIO.zip` (or the legacy OS package) from the
[latest release](https://github.com/pdev-labs/TeleZip/releases/latest) and extract it.

**Option B — Clone**
```bash
git clone https://github.com/pdev-labs/TeleZip.git
cd TeleZip
```

Make the shell scripts executable (first time only, Linux/macOS):
```bash
chmod +x *.sh
```

---

## ⚙️ Configuration

Run the wizard once — it writes a space-separated `.conf` file **next to the scripts**:

- Linux/macOS: `./initialize.sh`
- Windows: `.\initialize.ps1`

You'll be asked for: API ID, API Hash, App Title, App Short Name, Bot Token, Chat ID.

Resulting `.conf` format (one `key value` pair per line — keep the exact key names):

```text
api_id YOUR_API_ID
api_hash YOUR_API_HASH
app title YOUR_APP_TITLE
short name YOUR_SHORT_NAME
bot_token YOUR_BOT_TOKEN
chat_id YOUR_CHAT_ID
```

Notes:
- `.conf` is gitignored — it holds live secrets. **Never commit it, paste it into issues, or bake real values into docs/tests.**
- Which keys each tool actually reads:
  - `start_bot_api` → `api_id`, `api_hash`
  - `upload_telegram` / AIO upload → `bot_token`, `chat_id`
  - AIO → optional `api_url` (defaults to `http://127.0.0.1:8081` if absent)
  - `app title` / `short name` are stored for the API-server registration context but are not consumed by the upload flow.
- `.conf` lookup: `upload_telegram.sh` and `start_bot_api.sh` read `.conf` from **their own script directory** first, then fall back to `./.conf`. The `.ps1` scripts use `$PSScriptRoot\.conf`. So you can invoke them from any working directory (e.g. `bash /path/to/upload_telegram.sh`) and they still find their config. If a script still prompts for token/chat ID even though `.conf` exists, the file isn't where the script looks — check the script's directory, not your `cwd`.
- To reconfigure, just re-run the wizard (it overwrites `.conf`).

---

## 🚀 Usage — AIO (recommended)

### 1. Start the local API server (required for >50 MB files)

- Linux/macOS: `./start_bot_api.sh`
- Windows: `.\start_bot_api.ps1`

This (re)creates the `telegram-bot-api` container:

```bash
docker run -d -p 8081:8081 --name telegram-bot-api --restart=always \
  -v telegram-bot-api-data:/var/lib/telegram-bot-api \
  -e TELEGRAM_API_ID="$API_ID" \
  -e TELEGRAM_API_HASH="$API_HASH" \
  aiogram/telegram-bot-api:latest
```

Expected output: `✅ Success! The Telegram Bot API server is now running in the background.` Uploads then go to `http://127.0.0.1:8081`. Keep it running for the whole backup.

### 2. Run the backup

```bash
python3 telezip_aio.py
```

The script is fully interactive — there are no CLI flags. Example session:

```text
==================================================
🚀 TeleZip AIO (All-In-One) Master Script
==================================================
Enter the parent folder to backup: /home/user/photos
🔒 Do you want to encrypt the zips with a password? (y/N): n
🗑️ Do you want to automatically DELETE local zip files after successful upload? (y/N): n
🚫 Enter any folders to exclude (comma separated, e.g., node_modules,.git) or press Enter to skip: .git,node_modules

🔄 Zipping 5 folders in parallel...
📦 Zipping trip-2024...
...

🚀 Uploading 5 files in parallel...
🚀 Uploading trip-2024.zip (812.44 MB)...
✅ Success: trip-2024.zip
...
📢 Sending final summary notification...

==================================================
🎉 All Done! Successfully backed up 5 folders.
==================================================
```

Behavior worth knowing:
- **Output location:** zips go to `<parent>/<parent>-zip/` (e.g. backing up `photos` creates `photos/photos-zip/`). That folder is automatically excluded from the zip scan.
- **No subfolders → clean exit** with `No subfolders found.` (files sitting directly in the parent dir are *not* zipped — only immediate subdirectories).
- **Encryption** uses `zip -r -P`. Note the password is visible in the process list while zipping; prefer a dedicated backup secret, not a reused personal password.
- **Exclusions** are substring matches (`-x *node_modules*`), applied to every folder.
- **Resume:** state lives in `.telezip_state.json` in the directory where you run the script. Interrupted run? Just run it again — uploaded entries are skipped. To re-upload everything, delete `.telezip_state.json` (and keep the zips, unless you enabled auto-cleanup).
- **Summary message** is sent to your chat via `sendMessage` even if some uploads failed — compare its count against the per-file `✅/❌` lines.
- **Size cap:** the legacy upload scripts refuse files ≥ 2000 MB (Telegram's hard bot limit even locally). The AIO script does not pre-check — oversize files will simply fail at the API with `❌ Failed … (HTTP …)` and can be retried after splitting.

---

## 🧩 Usage — Legacy scripts (no Python)

Run in this order:

| Step | Linux/macOS/Termux | Windows | What it does |
|---|---|---|---|
| 1. Configure | `./initialize.sh` | `.\initialize.ps1` | Writes `.conf` |
| 2. Zip | `./auto_zip.sh [parent_dir]` (prompts if omitted) | `.\auto_zip.ps1 [-ParentDir …]` (prompts if omitted) | Zips each subfolder into `<parent>/<parent>-zip/` |
| 3. Serve | `./start_bot_api.sh` | `.\start_bot_api.ps1` | Starts the local 2 GB API server |
| 4. Upload | `./upload_telegram.sh` | `.\upload_telegram.ps1` | Uploads all `*.zip` from the chosen folder |

Upload-script flow detail:
1. Reads `bot_token`/`chat_id` from `.conf` (script dir, then `cwd`); prompts only if missing.
2. Looks for a `*-zip` directory in your **current** directory and offers it (`Should I start uploading? (y/N)`); otherwise prompts for the zip folder path.
3. Uploads each `*.zip` sequentially with progress, printing `✅ Successfully uploaded …` or `❌ Failed …` with the HTTP status and Telegram response body.

---

## 🗂️ Project structure

```text
TeleZip/
├── telezip_aio.py        # AIO master script (stdlib only + zip/curl/docker CLIs)
├── initialize.sh/.ps1    # Setup wizard → writes .conf
├── auto_zip.sh/.ps1      # Legacy per-folder compression
├── start_bot_api.sh/.ps1 # Legacy local Bot API server launcher (Docker)
├── upload_telegram.sh/.ps1 # Legacy sequential uploader
├── .conf                # YOUR secrets (gitignored, created by wizard — never commit)
├── .telezip_state.json  # AIO resume state (created at runtime — safe to delete to reset)
└── LICENSE              # GPL-3.0
```

There is no test suite, linter config, CI workflow, or package manifest — verification is `python3 -c "import ast; ast.parse(open('telezip_aio.py').read())"` plus `bash -n` on the shell scripts.

---

## 🩺 Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `Error: .conf file not found. Please run the setup wizard first.` (AIO) | You ran `telezip_aio.py` from a directory without `.conf`. `cd` into the TeleZip folder (or copy `.conf` next to where you run it) and retry. |
| Script asks for Bot Token / Chat ID even though `.conf` exists | The lookup is script-dir-first. If you copied a script elsewhere without its `.conf`, it won't find it. Keep each script beside `.conf`, or re-run the wizard. (This was a hard failure before the path fix — `upload_telegram.sh` used to point at a stale absolute path.) |
| `Error: Could not extract api_id or api_hash` | `.conf` is malformed — keys must be exactly `api_id …` / `api_hash …` on their own lines. Re-run the wizard. |
| `Docker is not running` | Start the Docker daemon/Desktop first. On Arch: `sudo systemctl start docker`. The `start_bot_api.sh` path uses `sudo docker`; ensure your user has Docker rights. |
| `curl: command not found` / `zip: command not found` | Install via your package manager. `auto_zip.sh` auto-installs `zip`; the upload scripts only print the hint. |
| `No subfolders found` | The parent contains files but no directories — by design only immediate subfolders are zipped. |
| `❌ Failed … (HTTP 413/400)` | File likely ≥ 2000 MB (hard Telegram bot limit) or the local API server isn't running — confirm `./start_bot_api.sh` succeeded and `curl http://127.0.0.1:8081` answers. |
| Resume re-uploads everything | You deleted `.telezip_state.json`, renamed zips, or run from a different directory (state file is `cwd`-relative). |
| `Failed to send summary` | Uploads may still have succeeded — the final `sendMessage` is best-effort over `urllib`. Check the chat and the per-file lines. |

---

## 🔐 Security notes

- `.conf` contains `bot_token` and `api_hash` — treat it like a password file (`chmod 600 .conf`, never commit, never screenshot into issues).
- `zip -P` encryption is the classic ZipCrypto/legacy scheme and the password appears in `ps` output during compression. Good enough against casual snooping, not a substitute for strong at-rest encryption of highly sensitive data.
- The local Bot API server binds `127.0.0.1:8081` — don't expose that port publicly; anyone who can reach it with your token can post as your bot.

---

## 📄 License

GNU General Public License v3.0 — see [LICENSE](LICENSE).
