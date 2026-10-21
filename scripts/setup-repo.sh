#!/usr/bin/env bash
# Applies repo settings and labels with the gh CLI. Safe to re-run.
set -euo pipefail
REPO=${REPO:-simvora/simvora-issues}
DIR=$(cd "$(dirname "$0")/.." && pwd)

gh repo edit "$REPO" \
  --description "Report bugs, wrong content and ideas for simvora.dev" \
  --homepage "https://simvora.dev" \
  --enable-issues --enable-wiki=false --enable-projects=false \
  --add-topic simvora,system-design,issue-tracker

# GitHub's defaults we don't use
for l in documentation "help wanted" "good first issue" invalid question; do
  gh label delete "$l" -R "$REPO" --yes 2>/dev/null || true
done

python3 -c 'import json,sys
for l in json.load(open(sys.argv[1])): print("\t".join([l["name"], l["color"], l["description"]]))' \
  "$DIR/.github/labels.json" |
while IFS=$'\t' read -r name color desc; do
  gh label create "$name" -R "$REPO" --force --color "$color" --description "$desc"
done
