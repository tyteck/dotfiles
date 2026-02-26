#!/usr/bin/env bash
set -euo pipefail

REPOS=(
  "actualtysoft/nina"
  "actualtysoft/anael-api-handler"
  "actualtysoft/scud-api-handler"
)

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
CYAN='\033[1;36m'
RESET='\033[0m'

print_section() {
  local color="$1" title="$2" content="$3"
  echo -e "\n${color}=== ${title} ===${RESET}"
  if [[ -z "$content" ]]; then
    echo "(aucune)"
  else
    echo "$content"
  fi
}

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Fetch all authored PRs per repo + review-requested, all in parallel
for repo in "${REPOS[@]}"; do
  gh pr list --repo "$repo" --author "@me" --state open \
    --json url,title,reviewDecision > "$tmpdir/${repo//\//_}.json" &
done

gh search prs --review-requested=@me --state=open --owner=actualtysoft \
  --json url,title,repository > "$tmpdir/to_review.json" &

wait

# Merge all authored PRs into one array
jq -s 'add // []' "$tmpdir"/actualtysoft_*.json > "$tmpdir/authored.json"

# Filter each category locally
waiting=$(jq -r '.[] | select(.reviewDecision == "" or .reviewDecision == "REVIEW_REQUIRED") | "\(.url)  \(.title)"' "$tmpdir/authored.json")
approved=$(jq -r '.[] | select(.reviewDecision == "APPROVED") | "\(.url)  \(.title)"' "$tmpdir/authored.json")
changes=$(jq -r '.[] | select(.reviewDecision == "CHANGES_REQUESTED") | "\(.url)  \(.title)"' "$tmpdir/authored.json")

# Filter review-requested by target repos
repo_json=$(printf '%s\n' "${REPOS[@]}" | jq -R -s 'split("\n") | map(select(. != ""))')
to_review=$(jq -r --argjson repos "$repo_json" \
  '.[] | select(.repository.nameWithOwner as $r | $repos | index($r)) | "\(.url)  \(.title)"' \
  "$tmpdir/to_review.json")

# Output
print_section "$YELLOW" "Mes PRs en attente de review" "$waiting"
print_section "$GREEN"  "Mes PRs approuvées (prêtes à merge)" "$approved"
print_section "$RED"    "Mes PRs avec changements demandés" "$changes"
print_section "$CYAN"   "PRs à reviewer" "$to_review"

echo ""
