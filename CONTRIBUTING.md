# Contributing to TeleZip

Thanks for helping out. This is a small, single-purpose toolkit, so the bar is: keep it simple, keep the platforms in parity, and never leak secrets.

## How to contribute

1. Fork the repo and create a branch from `main` (`fix/…`, `feat/…`, `docs/…`).
2. Make your change, verify it (below), and open a pull request against `main`.
3. Keep PRs focused — one fix or feature per PR.

## Rules that matter here

- **Shell/PowerShell parity.** Every legacy workflow exists as both `.sh` and `.ps1`. If you change one, mirror the behavior in the other (`.conf` lookup, prompts, exit conditions).
- **`.conf` format is frozen.** Space-separated `key value`, one per line, exact key names (`api_id`, `api_hash`, `bot_token`, `chat_id`). All readers (Python `split(' ', 1)`, `awk`, PowerShell regex) depend on it — test every reader if you touch it.
- **No secrets in the repo.** Never commit `.conf`, tokens, hashes, or chat IDs — not in code, docs, tests, or screenshots. `.conf` and `.telezip_state.json` are gitignored; keep it that way.
- **No new dependencies.** `telezip_aio.py` is stdlib-only by design (plus the `zip`, `curl`, `docker` CLIs). Don't add pip packages.
- **AIO stays flag-free.** The master script is fully interactive with no CLI args — document new prompts in `README.md` instead of adding argparse.

## Verification

No test suite exists; run the applicable checks before opening a PR:

```bash
python3 -m py_compile telezip_aio.py
bash -n initialize.sh auto_zip.sh start_bot_api.sh upload_telegram.sh
git ls-files | grep -qx '.conf' && echo 'FAIL: .conf tracked' || echo 'OK: no secrets tracked'
```

If you changed upload/zip behavior, also do a dry end-to-end run with dummy credentials (see `README.md` → Troubleshooting) and note it in the PR.

## Releases

Maintainers cut releases with three assets built from the tagged tree (no `.conf`, no state files):

- `TeleZip-AIO.zip` — `telezip_aio.py`, `README.md`, `LICENSE`
- `TeleZip-Unix.zip` — the four `.sh` scripts, `README.md`, `LICENSE`
- `TeleZip-Windows.zip` — the four `.ps1` scripts, `README.md`, `LICENSE`

Versioning is SemVer (`vMAJOR.MINOR.PATCH`).
