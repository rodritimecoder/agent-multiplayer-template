#!/usr/bin/env bash
set -euo pipefail

REPO_NAME="${1:-agent-multiplayer-template}"
VISIBILITY="${2:---private}" # pass --public or --private

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init -b main
fi

git add -A
git commit -m "feat: initialize multiplayer cloud workspace & homelab GPU bridge" || true

# Create repo on GitHub and push
gh repo create "$REPO_NAME" "$VISIBILITY" --source=. --remote=origin --push

# Mark the repository as a reusable GitHub Template Repository via API
OWNER_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
gh api -X PATCH "repos/${OWNER_REPO}" -f is_template=true >/dev/null

# Replace placeholder badge URL in README.md with actual owner/repo (Cross-platform Python replacement)
python3 -c "
with open('README.md', 'r') as f:
    c = f.read()
c = c.replace('YOUR_USER/YOUR_REPO', '${OWNER_REPO}')
with open('README.md', 'w') as f:
    f.write(c)
"
git add README.md && git commit -m "docs: bind Codespaces badge to ${OWNER_REPO}" && git push

echo "============================================================"
echo "Template Repo Published: https://github.com/${OWNER_REPO}"
echo "Launch Codespace:        https://codespaces.new/${OWNER_REPO}"
echo "============================================================"
