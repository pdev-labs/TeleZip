# Security Policy

## Reporting a vulnerability

Please **do not open a public issue** for security problems. Use
[private vulnerability reporting](../../security/advisories/new) on the
Security tab instead. Include:

- which script and version/tag is affected,
- steps to reproduce (with **redacted** credentials — never send real
  `bot_token`, `api_hash`, or `chat_id` values),
- what you expected vs. what happened.

We aim to acknowledge reports within a week. This is a
maintainer-in-spare-time project, so fixes land on a best-effort basis;
severity (credential exposure, remote code execution) sets priority.

## Secrets hygiene (please read)

TeleZip's `.conf` holds a Telegram **bot token** and **API hash**.
Anyone with the bot token can post as your bot.

- `.conf` is gitignored and must never be committed. If you accidentally
  push one: **revoke it immediately** — new token via [@BotFather](https://t.me/BotFather)
  (`/revoke`), new API hash via [my.telegram.org](https://my.telegram.org/) —
  then rewrite the published history. Treat the old credentials as burned.
- Don't paste `.conf` contents, tokens, or chat IDs into issues, PRs,
  discussions, or screenshots. Reports containing secrets will be edited
  or deleted, and you'll be asked to rotate the exposed credentials.
- Restrict the file locally: `chmod 600 .conf`.
- The local Bot API server listens on `127.0.0.1:8081`. Do not expose
  that port beyond localhost.
- `zip -P` passwords are visible in the process list during compression;
  use a dedicated backup password, not a reused personal one.

## Supported versions

| Version | Supported |
|---|---|
| Latest release (`v2.x`) | ✅ |
| Older releases | ❌ (please upgrade and re-test first) |
