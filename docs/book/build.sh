#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

mkdir -p docs/book/dist

tmpdir="$(mktemp -d "${TMPDIR:-/data/data/com.termux/files/usr/tmp}/omnighost-book.XXXXXX")"
trap 'rm -rf "$tmpdir"' EXIT

version="$(node -p "require('./package.json').version")"
if [[ -z "$version" ]]; then
  echo "could not read version from package.json" >&2
  exit 1
fi

title_stem="$(
  awk -F: '
    $1 ~ /^[[:space:]]*title_stem[[:space:]]*$/ {
      value = $2
      sub(/^[[:space:]]*/, "", value)
      sub(/[[:space:]]*$/, "", value)
      gsub(/^["'\''"]|["'\''"]$/, "", value)
      print value
      exit
    }
  ' docs/book/metadata.yaml
)"
if [[ -z "$title_stem" ]]; then
  title_stem="obsidian"
fi

pubdate="$(date -u +%F)"
githash="$(git rev-parse --short=6 HEAD 2>/dev/null || echo nogit)"
version_stamp="$version-$githash"
kindle_name="$title_stem ($version)"
link_stem="$title_stem ($version_stamp)"

stable_epub="docs/book/dist/$title_stem.epub"
stable_pdf="docs/book/dist/$title_stem.pdf"
versioned_epub="docs/book/dist/$link_stem.epub"
versioned_pdf="docs/book/dist/$link_stem.pdf"

docs/book/render-diagrams.sh

{
  printf 'kindle_name: %s\n' "$kindle_name"
  printf 'version_stamp: %s\n' "$version_stamp"
  printf 'built_at: %s\n' "$pubdate"
  printf 'epub_file: %s.epub\n' "$title_stem"
  printf 'pdf_file: %s.pdf\n' "$title_stem"
  printf 'epub_link: %s.epub\n' "$link_stem"
  printf 'pdf_link: %s.pdf\n' "$link_stem"
} > docs/book/dist/VERSION.md

sed "s/{{KINDLE_NAME}}/$kindle_name/g" docs/book/cover.md > "$tmpdir/cover.md"
awk '
  /^```[{]=typst[}]/ { in_block = 1; next }
  in_block && /^```$/ { exit }
  in_block { print }
' "$tmpdir/cover.md" > "$tmpdir/cover.typ"

typst compile "$tmpdir/cover.typ" "$tmpdir/cover.pdf"

pandoc docs/book/omnighost.md \
  -o "$tmpdir/body.pdf" \
  --pdf-engine=typst \
  --toc \
  --number-sections

pdfunite "$tmpdir/cover.pdf" "$tmpdir/body.pdf" "$stable_pdf"

pandoc "$tmpdir/cover.md" docs/book/omnighost.md \
  -o "$stable_epub" \
  --toc \
  --number-sections \
  --metadata-file docs/book/metadata.yaml \
  --metadata date="$pubdate" \
  --css docs/book/epub.css \
  --epub-title-page=false

docs/book/fix_epub_layout.sh "$stable_epub" "$kindle_name"

find docs/book/dist -maxdepth 1 \
  \( -name "$title_stem (*).epub" -o -name "$title_stem (*).pdf" \) -delete
ln -s "$(basename "$stable_epub")" "$versioned_epub"
ln -s "$(basename "$stable_pdf")" "$versioned_pdf"

docs/book/check_epub_metadata.sh "$stable_epub" "$kindle_name"

if command -v ebook-convert >/dev/null 2>&1; then
  ebook-convert "$stable_epub" "docs/book/dist/$title_stem.mobi"
else
  echo "ebook-convert not found; skipped MOBI build" >&2
fi
