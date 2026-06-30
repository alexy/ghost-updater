# Omnighost Book Publishing Workflow

Use this runbook when updating or rebuilding **Obsidian on the Go**, the local
book recovered from `docs/book/dist/obsidian-0.1.0-a9ae50.epub`.

## Source layout

- Manuscript: `docs/book/omnighost.md`
- Cover source: `docs/book/cover.md`
- Metadata: `docs/book/metadata.yaml`
- Mermaid diagram sources: `docs/book/diagrams/*.mmd`
- Rendered diagram PNGs: `docs/book/diagrams/*.png`
- Screenshots extracted from the EPUB: `docs/book/media/*.png`
- Build script: `docs/book/build.sh`
- Diagram render script: `docs/book/render-diagrams.sh`
- EPUB fixer: `docs/book/fix_epub_layout.sh`
- EPUB validator: `docs/book/check_epub_metadata.sh`
- Artifacts: `docs/book/dist/`

## Artifact contract

Stable deliverables:

- `docs/book/dist/obsidian.pdf`
- `docs/book/dist/obsidian.epub`
- `docs/book/dist/VERSION.md`

Versioned delivery links are generated on each build:

```text
docs/book/dist/obsidian (<package-version>-<short-commit>).epub -> obsidian.epub
docs/book/dist/obsidian (<package-version>-<short-commit>).pdf  -> obsidian.pdf
```

`VERSION.md` records:

```yaml
kindle_name: obsidian (<package-version>)
version_stamp: <package-version>-<short-commit>
built_at: YYYY-MM-DD
epub_file: obsidian.epub
pdf_file: obsidian.pdf
epub_link: obsidian (<package-version>-<short-commit>).epub
pdf_link: obsidian (<package-version>-<short-commit>).pdf
```

MOBI conversion is optional and only runs when `ebook-convert` is installed.

## Metadata rules

The visible title stays clean:

```text
Obsidian on the Go
```

The Kindle/catalog title is versioned:

```text
obsidian (<package-version>)
```

Keep those surfaces separate:

- Cover, NCX, navigation title, and visible table of contents: `Obsidian on the Go`
- OPF `dc:title` and title-sort metadata: `obsidian (<package-version>)`
- Stable artifact names: `obsidian.epub`, `obsidian.pdf`
- Versioned delivery links: `obsidian (<package-version>-<short-commit>).{epub,pdf}`

The version comes from root `package.json`.

## Mermaid diagrams

Diagrams are source-controlled as `.mmd` files and rendered to PNGs committed
next to them. The manuscript references the PNGs so GitHub, EPUB, PDF, and blog
extracts all see stable images.

Render all diagrams:

```sh
docs/book/render-diagrams.sh
```

The render script uses `mmdc`, `docs/book/puppeteer-config.json`, and the local
`node_modules/.bin` first. On Termux, Chromium must run with `--single-process`;
that is already in the Puppeteer config.

## Build

From the repository root:

```sh
docs/book/build.sh
```

The build script:

1. Reads the plugin version from `package.json`.
2. Reads `title_stem` from `docs/book/metadata.yaml`.
3. Renders Mermaid `.mmd` files to PNG.
4. Writes `docs/book/dist/VERSION.md`.
5. Renders a temporary cover with `{{KINDLE_NAME}}` replaced.
6. Builds a standalone cover PDF.
7. Builds the body PDF with table of contents and numbered sections.
8. Merges cover PDF before body PDF into `docs/book/dist/obsidian.pdf`.
9. Builds `docs/book/dist/obsidian.epub`.
10. Repairs EPUB cover/nav ordering and Kindle-facing metadata.
11. Creates versioned EPUB/PDF symlinks.
12. Validates EPUB metadata and layout.
13. Builds `obsidian.mobi` only if `ebook-convert` exists.

## Required validation

After a build:

```sh
expected_title=$(awk -F': ' '/^kindle_name:/ { print $2 }' docs/book/dist/VERSION.md)
docs/book/check_epub_metadata.sh docs/book/dist/obsidian.epub "$expected_title"
git diff --check
```

For PDF page numbering:

```sh
pdftotext -f 1 -l 1 docs/book/dist/obsidian.pdf -
pdftotext -f 2 -l 2 docs/book/dist/obsidian.pdf -
```

Expected:

- Page 1 extracts cover text and no standalone page number.
- Page 2 contains the table of contents/body and starts body numbering.

## Blog diagrams

When turning a book section into a blog post, keep the same convention:

- write diagram source as `diagrams/<name>.mmd`;
- render and commit `diagrams/<name>.png`;
- reference the PNG from Markdown.

Do not rely on raw Mermaid blocks for Ghost/mobile delivery; materialized PNGs
are the portable format.
