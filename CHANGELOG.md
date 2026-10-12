# Changelog

All notable changes to this project are documented here. Versioning
follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Fixed

- AIO auto-cleanup crash: sizes are now captured before uploading
  (`select_uploads`), so answering `y` to delete-after-upload no longer
  ends in `FileNotFoundError` with no summary message.
- AIO summary accounting: each upload future is mapped to its own
  `(path, size)` instead of positionally zipping `as_completed()` output
  with the path list.
- AIO resume-state race: all `state` reads/writes and saves are now
  guarded by a lock across the upload threads.
- AIO now validates that `.conf` contains `bot_token` and `chat_id` with
  a friendly error instead of a `KeyError` traceback.
- AIO now skips files at/above Telegram's 2000 MB per-file bot limit
  with a warning, matching the legacy upload scripts.

## [v2.0.1] — 2026-10-12

### Fixed

- `upload_telegram.sh` and `start_bot_api.sh` now resolve `.conf` from
  their own script directory (with a `./.conf` fallback) instead of a
  stale absolute path — existing configs are found and credentials are
  no longer re-prompted.

### Documentation

- Rewrote `README.md` as a full guide: setup, AIO and legacy usage,
  `.conf` reference, project structure, troubleshooting, security notes.
- Added `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, issue/PR
  templates, and a CI workflow.

## [v2.0.0] — 2026-09-27

- Introduced `telezip_aio.py`: unified script with parallel zipping and
  uploading, pause/resume via `.telezip_state.json`, auto-cleanup,
  exclusions, zip passwords, captions, and a final summary message.

## [v1.0.0] — 2026-09-27

- Initial release: per-step `initialize` / `auto_zip` / `start_bot_api` /
  `upload_telegram` scripts for Unix (`.sh`) and Windows (`.ps1`) plus a
  local Dockerized Telegram Bot API server for 2 GB uploads.
