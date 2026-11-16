---
name: wordpress-security-rescue
description: Autonomous WordPress hack investigation, hidden SEO-spam detection, and surgical server recovery over SSH/cPanel/WP-CLI. Built for both non-technical site owners and engineers: enforces a mandatory full local backup first, maps hidden cloaking/backdoors in 15 minutes in read-only mode, and requires explicit human approval before every live fix.
version: 1.0.0
license: MIT
---

# WordPress Security Rescue & Forensics Skill

An evidence-first, safety-locked workflow for investigating and recovering compromised WordPress sites over SSH, WP-CLI, and cPanel API.

Designed so **non-technical site owners** can hand their server to a top AI coding agent (`Claude Code`, `Antigravity`, `Cursor`) without risking accidental data loss.

---

## Mandatory Safety Contract (Never Skip)

Before running any diagnostic or cleanup command on a live server, you MUST enforce these three rules:

1. **Rule 1 — Full Local Backup Before Anything Else:**
   - Do not modify, delete, or update a single file or database row until a complete backup is downloaded locally.
   - If the user says *"scan first, don't change anything"*, stay strictly in **Read-Only Mode** (`Phase 1` & `Phase 2`).
2. **Rule 2 — Human Approval Gate on Every Write:**
   - Explain every proposed change in plain everyday language (what will change, why, and how to roll it back in 60 seconds) and wait for explicit user approval (`yes` / `approved`) before executing any write command.
3. **Rule 3 — Zero Secret Exposure:**
   - Never print database passwords, cPanel tokens, `wp-config.php` salts, or unblurred 2FA QR/secret keys into the chat transcript.

---

## Plain-Language Onboarding for Non-Technical Site Owners

If the user is a business owner or non-developer who just wants to check if their WordPress site is hacked, guide them through these 3 simple steps in plain language instead of asking for complex terminal setup:

1. **Turn on SSH Access in Hosting (GoDaddy / cPanel):**
   - Open your hosting dashboard -> **cPanel** -> **SSH Access** (on GoDaddy shared hosting, shell access is off by default; click **Manage SSH** -> **Enable**).
2. **Create an SSH Key or cPanel API Token:**
   - Tell the agent: *"Help me connect to my cPanel / WordPress server over SSH."* The agent will generate an SSH key locally and show you exactly where to paste the public key in cPanel (`SSH Access -> Manage SSH Keys -> Import Key -> Authorize`).
3. **Start in Read-Only Audit Mode:**
   - Tell the agent: *"Make a full backup first, then scan my WordPress files, databases, and logs for hacks or hidden links. Do not change anything on the server yet."*

---

## Phase 1 — Connection & Pre-Flight Verification

1. **Verify Target Domains & Document Roots:**
   - Never assume the domain name from the prompt matches the folder name on the server (typos like `smar...` vs `smart...` are common).
   - List all addon domains and document roots via cPanel `uapi` or `wp option get siteurl` inside each WordPress directory.
2. **Check Available Disk Space Before Backup:**
   - Run `df -h` on the remote server and local machine. Never create large temporary archives on a nearly full hosting disk; stream `tar` and `mysqldump` directly over SSH to the local backup folder.

---

## Phase 2 — Non-Destructive Full Local Backup

Create a dated local folder `./backups/YYYY-MM-DD/` (ensure `backups/` is in `.gitignore`) and pull:

1. **All Site Files:**
   ```bash
   ssh user@host "tar -czf - -C /home/user/public_html ." > ./backups/YYYY-MM-DD/files_site.tar.gz
   ```
2. **All Databases in Two Encodings (Critical for Non-ASCII Text):**
   - Standard UTF-8 dump PLUS a **byte-exact `latin1` dump** (`--default-character-set=latin1 --skip-set-charset`). Legacy WordPress tables often store UTF-8 bytes inside `latin1` columns; a byte-exact dump prevents corrupting Polish, German, Cyrillic, or accented characters during surgical restores:
   ```bash
   ssh user@host "mysqldump --default-character-set=latin1 --skip-set-charset -u DB_USER -p'DB_PASS' DB_NAME | gzip -c" > ./backups/YYYY-MM-DD/db_site.latin1.sql.gz
   ```
3. **Raw Access Logs & Error Logs:**
   - Pull `~/logs/` and `/home/user/access-logs/` for the last 60 days so login attempts, IP addresses, and timestamps are preserved before log rotation overwrites them.

---

## Phase 3 — 15-Minute Read-Only Forensics (7 Checks)

Run all 7 forensic checks without modifying the server and present a clear, plain-language summary table:

### Check 1: WordPress Core Integrity
```bash
wp core verify-checksums
```
- Flags any modified core file or unexpected `.php` file inside `wp-admin/` and `wp-includes/`.

### Check 2: Hidden SEO Spam & Off-Screen CSS Cloaking in Database
Visual browser checks miss SEO spam because attackers push links off screen or shrink them to 1px while leaving them in the HTML for Googlebot. Query `wp_posts` directly (including old revisions!):
```sql
SELECT ID, post_type, post_status, post_title, post_modified
FROM wp_posts
WHERE post_content REGEXP 'left:[[:space:]]*-[0-9]{3,}|top:[[:space:]]*-[0-9]{3,}|font-size:[[:space:]]*[01]px|display:[[:space:]]*none.*<a[[:space:]]+href|casino|crypto|betting|microloan|loan|slot|roulette';
```
- **Check both live pages AND `post_type = 'revision'`.** Attackers often leave spam inside 5–10 page revisions so an innocent page rollback re-infects the site.
- Compare what a normal browser sees vs. what `Googlebot` sees:
  ```bash
  curl -sL -A "Mozilla/5.0" https://example.com > /tmp/human.html
  curl -sL -A "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" https://example.com > /tmp/googlebot.html
  diff -u /tmp/human.html /tmp/googlebot.html | head -n 60
  ```

### Check 3: Fake, Abandoned, and Nulled (Pirated) Plugins & Themes
- Run `wp plugin list` and `wp theme list`, then verify checksums:
  ```bash
  wp plugin verify-checksums --all
  ```
- Inspect any plugin that does not exist in the official `wordpress.org` directory (attackers plant disguised folders like `content-sync-helper` or `wp-cache-service`).
- Flag **nulled (unlicensed) premium plugins/themes** (e.g., `Elementor Pro`, `Flatsome`, `Smart Slider 3 Pro`). They cannot be verified against official checksums, stop receiving security patches, and cause fatal PHP errors when free companion plugins auto-update.
- Scan `wp-content/uploads/`, `wp-content/mu-plugins/`, `.htaccess`, and `wp-config.php` for PHP execution or obfuscated shells (`eval(`, `base64_decode(`, `gzinflate(`, `str_rot13(`, `FilesMan`, `passthru(`, `shell_exec(`).
- Check for **zero-byte files** in plugin/theme folders: hosting antivirus scanners often zero out a webshell file while leaving the attacker's stolen admin password active.

### Check 4: Public Backup Archives in Web Root (`HTTP 200` Leak)
Developers frequently leave `.zip`, `.tar.gz`, or `.sql` backups inside `public_html/`. Anyone who guesses or scans the URL can download the archive and read `wp-config.php` database credentials in plain text:
```bash
find ~/public_html -maxdepth 3 \( -iname "*.zip" -o -iname "*.tar*" -o -iname "*.sql*" -o -iname "*.bak" \) -ls
```
- Test whether any discovered archive returns `HTTP 200 OK` publicly.

### Check 5: Administrator Accounts & Foreign Emails in `wp_options`
- List all privileged users:
  ```bash
  wp user list --role=administrator --fields=ID,user_login,user_email,user_registered
  ```
- Search `wp_options` for legacy contractor or unknown emails receiving password resets, security alerts, WooCommerce notifications, or backup reports:
  ```bash
  wp db query "SELECT option_name, option_value FROM wp_options WHERE option_value LIKE '%@%' AND option_name NOT LIKE '\_transient%';"
  ```

### Check 6: Access Log & File Timestamp Forensics
- Check `wp-login.php` POST requests in access logs:
  - Did the attacker brute-force, or did they log in with `HTTP 302` on the **first try** using the real administrator's leaked password?
- Count `xmlrpc.php` POST floods (automated password guessing via `system.multicall`).
- Inspect file modification (`mtime`) and status change (`ctime`) timestamps around suspicious dates. Look for minute-by-minute sequences (for example, an attacker manually editing a vulnerable plugin at `10:53` to remove a public supply-chain backdoor, then uploading their own private fake plugin at `10:54` so rival bots cannot hijack the server).

### Check 7: Silent Auto-Update & CVE Exposure Check
- Check whether WordPress auto-updates are disabled while a hosting panel tool (**Installatron** / **Softaculous**) is silently force-updating plugins in the background.
- Cross-check installed plugin versions against known high-severity CVEs (e.g., WPML Twig shortcode RCE `CVE-2024-6386`, Smart Slider 3 unauthorized export `CVE-2026-3098`, closed wordpress.org plugins like `popup-anything-on-click`).

---

## Phase 4 — Human-Approved Surgical Cleanup & Recovery

Present the findings to the user first. Once approved, execute fixes in this exact order:

1. **Archive Every File or Table Before Touching It:**
   - Before deleting any suspicious plugin, archive, or backdoor folder, save a copy into `./backups/YYYY-MM-DD/pre-fix_removed.tar.gz`.
   - *Why this matters:* If a risky plugin (such as an admin File Manager plugin) is removed during cleanup and the client still relies on it for daily work, you can restore it in 60 seconds.
2. **Byte-Exact Database Spam Removal (With MD5 Verification & Revision Purge):**
   - Export `wp_posts` before editing.
   - Strip only the hidden spam blocks while leaving visible page text 100% intact.
   - Verify the `MD5(post_content)` of each target row before executing `UPDATE`.
   - Delete or clean all infected `post_type = 'revision'` rows so rolling back a page cannot resurrect the hidden links.
3. **Safe Email Replacement Across Serialized Data:**
   - Never run raw SQL `REPLACE()` on `wp_options` or `wp_postmeta` — it breaks PHP serialized string lengths (`s:24:"..."`). Always use WP-CLI:
     ```bash
     wp search-replace 'old-contractor@example.com' 'owner@example.com' --all-tables --precise --dry-run
     ```
4. **Remove Public Archives & Disguised Plugins:**
   - Delete exposed `.zip`/`.sql` archives from `public_html` and verify their URLs now return `HTTP 404`.
   - Remove fake plugins and block `xmlrpc.php` across all sites via `.htaccess`:
     ```apache
     <Files xmlrpc.php>
       Order Deny,Allow
       Deny from all
     </Files>
     ```
5. **Evict Active Attacker Sessions & Rotate Credentials:**
   - **Critical:** Changing a WordPress admin password alone does NOT log out an attacker who already has a valid session cookie. Always shuffle `wp-config.php` salts immediately:
     ```bash
     wp config shuffle-salts
     ```
   - Rotate the MySQL database user password via cPanel `uapi` and update `wp-config.php` directly on the server without echoing the password to stdout.
6. **Targeted One-Line Hotfixes for Legacy Plugins:**
   - When a legacy or custom plugin has a critical vulnerability and cannot be replaced immediately, apply a minimal targeted patch (after backing up the file) rather than rewriting the entire theme or plugin.
   - If a theme vulnerability requires an authenticated role that does not exist on the site (e.g., `Author` XSS when only admins exist), document the risk boundary instead of making high-risk edits across dozens of template files.
7. **Enforce Mandatory 2FA (With Per-User Grace Period Verification):**
   - Note: `Wordfence Login Security` was permanently closed on wordpress.org in August 2026; use actively maintained **WP 2FA** (`wp-2fa`) instead.
   - Disable duplicate email-2FA in secondary plugins (e.g., Really Simple Security) so users are not prompted twice.
   - **Gotcha to verify:** Some 2FA plugins calculate the grace-period expiry timestamp for only one user per PHP request. Verify in `wp_usermeta` that every administrator and editor has a valid grace-period timestamp.
   - If generating a PDF/Markdown setup guide for the team, **always blur QR codes and TOTP secret keys** in screenshots.

---

## Phase 5 — Final Verification & Handover Report

Before marking the rescue complete:
- Verify `HTTP 200` on all main pages and `wp-admin`.
- Verify `HTTP 403` on `/xmlrpc.php` and `HTTP 404` on any previously exposed `.zip` backup URLs.
- Re-run the `Googlebot` vs. browser `curl` check to confirm zero hidden links remain.
- Deliver a clear, non-technical **Handover Checklist** covering:
  1. What was found and cleaned.
  2. Which passwords the owner must rotate personally (hosting/cPanel/GoDaddy master password).
  3. Which nulled or abandoned plugins need paid licenses or clean replacements.
  4. Submitting a re-crawl request in **Google Search Console** (`Security Issues` & `URL Inspection -> Request Indexing`) so Google drops the cached casino/spam links from search results.
