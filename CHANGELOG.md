# Changelog

All notable changes to this project are documented here. Versioning
follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

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
