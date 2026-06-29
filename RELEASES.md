# Releases

Omnighost releases are codenamed after writers.

| Codename | Version | Date | Highlights |
|----------|---------|------|------------|
| **Borges** | 0.9.0 | 2026-06-28 | Multiple blogs + one-to-many publishing, and the project rename to **Omnighost** (id, repo, docs, and the companion book). Configure many Ghost blogs, each with its own site address, key, and folder; choose a note's target(s) with `g_blog` and sync it to all of them at once. Blog picker and per-blog published/draft **status rows** (clickable, copyable public URLs) in the edit-properties modal; **"Import all posts"** from a blog into a folder. Per-blog identity is stored as individual, clickable `g_id_<blog>` / `g_public_url_<blog>` properties — the origin blog keeps the clean `g_id`/`g_public_url`, and the old nested `g_ids`/`g_public_urls` maps are auto-migrated away. Each blog gets its **own keychain secret** with inline "Admin API key" entry, a collision warning when two blogs share one, and an **automatic connection test** when a key is saved. Sync notices name the blog (`Updated blog collected.ga: Thinking about life`). Fixes: cross-blog `g_id` 404 (the legacy id is attributed by URL host, not the current default blog), keyless blogs are skipped with a clear message instead of a cryptic 401, and sync errors name the failing blog. |
| **Pessoa** | 0.6.0 | 2026-06-28 | Publishing UX + reliability. Edit-properties modal (dropdowns for status/visibility, Save & Save & sync, live status indicator + clickable/copyable public URL); opt-in `cover_from_first_image`; ribbon + editor-menu access; "Migrate ghost property prefix", "Clear ghost image cache" commands; image cache moved to its own file; Test Connection reports the blog title. Fixes: property-only edits sync without a body edit, empty notes publish, `custom_excerpt` (no validation error), over-long slug capped, published indicator reflects what's actually live. |
| **Llorca** | 0.3.2 | 2026-06-27 | First named release. iOS/mobile support, image publishing with the cover-image trick + content-hash cache, in-place updates (`ghost_id` / explicit `g_slug`, no duplicates), seed-a-note-from-Ghost, public URL in frontmatter, public-by-default access. |

## On deck

Upcoming releases take the next writer in order:

1. **Borges** — current
2. **Márquez**
3. **Cortázar**
