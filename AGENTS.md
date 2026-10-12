# AGENTS.md — TeleZip

Single-purpose backup toolkit. Main path is `telezip_aio.py` (Python stdlib only, interactive); `.sh`/`.ps1` pairs are legacy per-step equivalents.

## Commands
- Run AIO: `python3 telezip_aio.py` — fully interactive (prompts for folder, password, cleanup, exclusions). No CLI args, no `--help`.
- Legacy Linux/macOS: `./initialize.sh` → `./auto_zip.sh [parent_dir]` → `./start_bot_api.sh` → `./upload_telegram.sh`
- Legacy Windows: `.\initialize.ps1`, `.\auto_zip.ps1`, `.\start_bot_api.ps1`, `.\upload_telegram.ps1`
- Syntax check only (no tests/lint/CI exist): `python3 -c "import ast; ast.parse(open('telezip_aio.py').read())"`
- External CLIs required at runtime, no pip deps: `zip`, `curl`, `docker`.

## Runtime order that matters
1. `initialize` writes `.conf` (space-separated `key value`, one per line).
2. `start_bot_api` launches Docker `aiogram/telegram-bot-api:latest` as container `telegram-bot-api` on `http://127.0.0.1:8081` (needed for >50MB, up to 2000MB uploads). Docker must already be running.
3. Only then zip/upload. AIO defaults `api_url` to `http://127.0.0.1:8081` if not in `.conf`.

## Gotchas (verified in code)
- `.conf` contains live secrets (`bot_token`, `api_hash`) and is gitignored — never print, commit, or add real values to docs/tests. Local `.conf` currently holds real credentials.
- `.conf` keys `app title` / `short name` contain spaces; `telezip_aio.py:23` splits on first space so only `bot_token`, `chat_id`, `api_id`, `api_hash` parse usefully. The app-title lines are effectively ignored by AIO — don't "fix" parsing without checking both `.sh` (`awk`) and `.ps1` (regex) readers.
- `.conf` lookup is script-dir based in `upload_telegram.sh` / `start_bot_api.sh` (`SCRIPT_DIR/.conf`, cwd fallback). If a script prompts for token/chat_id despite `.conf` existing, the lookup — not the file — regressed. `.ps1` versions use `$PSScriptRoot` the same way.
- AIO resume state `.telezip_state.json` (`load_state`/`save_state`) tracks uploaded `zip_path` strings; reruns skip them. Delete that file to force re-upload. `output_dir` is always `<parent>/<parent>-zip` and is excluded from its own input scan.
- AIO parallel-upload accounting is buggy: `telezip_aio.py:171` zips `as_completed(futures)` with `zip_paths`, mismatching results to sizes, and shares `state` dict across threads without a lock. Upload success itself is per-file correct; only the summary size/count can misreport.
- `zip -P` embeds the password visibly in the process list; `curl -F` upload parses HTTP code from last stdout line. Keep both subprocess approaches — no Python multipart lib is used intentionally.
- No test suite, lockfile, package manifest, CI, or formatter config exists. Don't add toolchain scaffolding unasked.
