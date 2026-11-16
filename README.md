# 🛡️ wordpress-security-rescue: AI-Assisted WordPress Hack Forensics & Surgical Recovery

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Compatible with Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-black?logo=anthropic)](https://claude.ai/code)
[![Compatible with Antigravity](https://img.shields.io/badge/Antigravity-Compatible-4285F4?logo=google)](https://deepmind.google)
[![Compatible with Cursor](https://img.shields.io/badge/Cursor-Compatible-000000)](https://cursor.com)
[![Standard: 2026 AI-Native](https://img.shields.io/badge/Standard-2026%20AI--Native-CC7A3E)](#)

An evidence-first **AI Agent Skill** that lets non-technical site owners and engineers investigate, clean, and harden compromised WordPress servers over SSH, WP-CLI, and cPanel — **without risking accidental damage**.

Built from real production incident forensics where a site looked completely normal in a browser while Google indexed hidden casino and crypto links (`position:absolute; left:-503011px`) for 5.5 months after a manual check declared it "all clean".

Part of the **[ILF Studio](https://ilf-studio.com)** & **[ilovefiniki.com](https://ilovefiniki.com)** engineering toolset.

---

## ⚡ Quickstart (1-Liner Installation)

Run this in your project root or local workspace:

```bash
# For Claude Code:
mkdir -p .claude/skills/wordpress-security-rescue && curl -fsSL https://raw.githubusercontent.com/ilovefiniki/wordpress-security-rescue/main/SKILL.md -o .claude/skills/wordpress-security-rescue/SKILL.md

# For Antigravity & Gemini:
mkdir -p .agents/skills/wordpress-security-rescue && curl -fsSL https://raw.githubusercontent.com/ilovefiniki/wordpress-security-rescue/main/SKILL.md -o .agents/skills/wordpress-security-rescue/SKILL.md

# Or run the universal installer:
curl -fsSL https://raw.githubusercontent.com/ilovefiniki/wordpress-security-rescue/main/scripts/install.sh | bash
```

---

## 🧭 Simple 3-Step Guide for Non-Technical Site Owners

You do **not** need to know Linux or SQL to audit your own WordPress site with an AI agent:

1. **Enable SSH in your hosting dashboard:**
   Open **cPanel -> SSH Access** and enable shell access (on hosts like GoDaddy, it is turned off by default).
2. **Install this skill and open your AI agent (`Claude Code`, `Antigravity`, or `Cursor`):**
   Paste the 1-liner above into your terminal, then tell the agent:
   > *"Use `wordpress-security-rescue`. Help me connect to my cPanel server over SSH, download a full local backup first, and scan my WordPress site in read-only mode. Do not change anything on the live server without my approval."*
3. **Review the 15-minute forensic report & approve fixes one by one:**
   The agent will verify core files, scan `wp_posts` (including old page revisions) for hidden off-screen links, check access logs, and ask for your confirmation before cleaning a single record.

---

## 🔒 The 5-Phase Safety Architecture

```
Phase 1: Pre-Flight ➔ Phase 2: Full Local Backup ➔ Phase 3: 15-Min Read-Only Forensics ➔ Phase 4: Approved Surgical Cleanup ➔ Phase 5: Hardening & 2FA
```

| Phase | What the Agent Does | Safety Boundary |
|---|---|---|
| **1. Pre-Flight** | Verifies actual document roots, addon domains, and disk space (`df -h`). | Zero server changes. |
| **2. Full Backup** | Streams site files (`tar.gz`), access logs, and databases in **both UTF-8 and byte-exact `latin1`** to your computer. | Mandatory before any fix. Enables 60-second rollback if a plugin is needed back. |
| **3. 15-Min Forensics** | Runs 7 read-only checks: core checksums, off-screen CSS spam (`left:-503011px`), Googlebot vs. human HTML diff, fake/nulled plugins, public `.zip` leaks, foreign emails in `wp_options`, and access log timestamps. | 100% Read-Only (`SELECT` / `verify-checksums`). |
| **4. Surgical Cleanup** | Strips hidden spam blocks from live posts and old revisions (`MD5` verified), replaces ex-contractor emails via `wp search-replace`, removes fake plugins, and blocks `xmlrpc.php`. | Requires explicit human approval (`yes`) before every write. |
| **5. Hardening & 2FA** | Shuffles `wp-config.php` salts to evict active attacker sessions, rotates DB passwords, patches legacy plugin CVEs, and configures TOTP 2FA. | Verifies `HTTP 200` on live pages and `403`/`404` on closed attack vectors. |

---

## 🕵️ What Manual Visual Checks Miss (And What This Skill Catches)

- **Off-Screen CSS Cloaking (`left: -503011px`):** Normal visitors see a clean corporate homepage; Googlebot indexes hidden gambling/crypto links pushed 133 meters to the left of the viewport.
- **Infected Page Revisions:** Removing spam from the live page is not enough if 9 old revisions in `wp_posts` still contain the links — a single content rollback brings the hack back.
- **First-Try Admin Logins:** Attackers often log in with the real administrator password leaked via a public `.zip` backup in `public_html`. Changing the password without shuffling `SALT` keys leaves their session active.
- **Backdoor Turf Wars:** Detects timestamp anomalies where an attacker manually patches a public plugin backdoor at `10:53` and plants their own disguised plugin at `10:54` to lock out rival bots.
- **Silent Installatron Collisions:** Catches cPanel auto-updaters updating free plugins against outdated nulled "Pro" plugins and crashing `wp-admin`.

---

## ⚙️ Environment Variables (Optional)

You can pass connection details interactively to your agent or set them in a local untracked `.env` file:

| Variable | Required | Description |
|---|---|---|
| `WP_SSH_HOST` | Optional | SSH hostname or IP address of your WordPress server |
| `WP_SSH_USER` | Optional | SSH / cPanel username |
| `WP_SSH_PORT` | Optional | SSH port (default: `22`) |
| `CPANEL_API_TOKEN` | Optional | cPanel UAPI token for domain & database credential rotation |
| `BACKUP_DIR` | Optional | Local directory for pre-audit backups (default: `./backups`) |

---

## 📁 Repository Structure

```text
wordpress-security-rescue/
├── SKILL.md             # Complete AI Agent instructions, SQL queries & safety gates
├── README.md            # Documentation & non-technical quickstart guide
├── scripts/
│   └── install.sh       # 1-liner cross-agent installer (Claude Code, Antigravity, Cursor, Windsurf)
├── LICENSE              # MIT License
└── .gitignore           # Excludes .env* and local backup archives
```

---

## 📄 License

MIT License — Created by **[Vitaliy Alhimovich](https://ilf-studio.com)** ([ilovefiniki.com](https://ilovefiniki.com)).
