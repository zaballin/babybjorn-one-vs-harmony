#!/usr/bin/env bash
# Publish the BabyBjörn One vs Harmony comparison as a public GitHub repo.
# Run with a token:  GH_TOKEN=ghp_xxx ./publish-github.sh
# Or run it interactively and paste the token when prompted.

set -euo pipefail

REPO_DIR="/root/.openclaw/workspace/babybjorn-one-vs-harmony"
REPO_NAME="babybjorn-one-vs-harmony"
GH_USER="zaballin"

cd "$REPO_DIR"

if [ -z "${GH_TOKEN:-}" ]; then
  echo "GH_TOKEN not set in environment."
  echo ""
  echo "Option A (recommended) — run 'gh auth login -h github.com --with-token' and pipe a token:"
  echo "  gh auth login -h github.com --with-token < token.txt"
  echo ""
  echo "Option B — set GH_TOKEN env var before running this script."
  echo ""
  read -rsp "Paste a GitHub token (hidden): " TOK; echo
  export GH_TOKEN="$TOK"
fi

if [ -z "${GH_TOKEN:-}" ]; then
  echo "No token available. Aborting." >&2
  exit 1
fi

echo "==> Authenticating with GitHub..."
gh auth status

echo "==> Creating public repo: ${GH_USER}/${REPO_NAME}"
if gh repo view "${GH_USER}/${REPO_NAME}" >/dev/null 2>&1; then
  echo "    Repo already exists, reusing it."
else
  gh repo create "${GH_USER}/${REPO_NAME}" \
    --public \
    --description "Detailed comparison of the BabyBjörn One Air vs Harmony carriers, focused on comfort and ease of use" \
    --source=. \
    --remote=origin
fi

echo "==> Committing"
git add -A
git -c user.name="${GIT_AUTHOR_NAME:-Jose}" \
    -c user.email="${GIT_AUTHOR_EMAIL:-$(gh api user --jq .email 2>/dev/null || echo 'zaballin@users.noreply.github.com')}" \
    commit -m "Add BabyBjörn One Air vs Harmony comparison

Detailed side-by-side of both carriers focused on comfort and ease of use:
weight ranges, padding and lumbar support, head support mechanisms, airflow,
adjustability, setup time, buckle behaviour, fit watch-outs, and forum
sentiment from Reddit, Mumsnet, MadeForMums and What to Expect.

Includes a recommendation (Harmony) with the conditions where the One Air
would be preferable. Single self-contained HTML file, no JS or external assets." || echo "    Nothing new to commit."

echo "==> Pushing"
git push -u origin main

echo ""
echo "==> Done. Public URL:"
gh repo view "${GH_USER}/${REPO_NAME}" --json url --jq .url
echo "    Pages/raw HTML: ${GH_USER}/${REPO_NAME}/blob/main/index.html"
