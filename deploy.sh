#!/usr/bin/env bash
# deploy.sh — publish JWT Decoder to GitHub Pages with custom domain jwt.ropean.org
set -euo pipefail

REPO_URL="${REPO_URL:-}"          # e.g. git@github.com:weiguo/jwt.git  (set via env or edit below)
CUSTOM_DOMAIN="jwt.ropean.org"
BRANCH="gh-pages"
BUILD_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP_DIR=$(mktemp -d)

# ── Resolve repo URL ─────────────────────────────────────────────────────────
if [ -z "$REPO_URL" ]; then
  # Try to read from existing git remote
  if git -C "$BUILD_DIR" remote get-url origin &>/dev/null; then
    REPO_URL=$(git -C "$BUILD_DIR" remote get-url origin)
  else
    echo "ERROR: No git remote found and REPO_URL is not set."
    echo "  Usage: REPO_URL=git@github.com:<user>/jwt.git ./deploy.sh"
    exit 1
  fi
fi

echo "→ Deploying to GitHub Pages"
echo "  Repo   : $REPO_URL"
echo "  Branch : $BRANCH"
echo "  Domain : $CUSTOM_DOMAIN"
echo ""

# ── Write CNAME ──────────────────────────────────────────────────────────────
echo "$CUSTOM_DOMAIN" > "$BUILD_DIR/CNAME"

# ── Prepare orphan gh-pages branch in tmp dir ────────────────────────────────
git clone --depth=1 "$REPO_URL" "$TMP_DIR" 2>/dev/null || true

cd "$TMP_DIR"

# Switch to gh-pages branch (create orphan if it doesn't exist)
if git ls-remote --exit-code --heads origin "$BRANCH" &>/dev/null; then
  git fetch origin "$BRANCH"
  git checkout "$BRANCH"
  # Remove everything (we'll replace with fresh build)
  git rm -rf . --quiet 2>/dev/null || true
else
  git checkout --orphan "$BRANCH"
  git rm -rf . --quiet 2>/dev/null || true
fi

# ── Copy build artifacts ──────────────────────────────────────────────────────
cp "$BUILD_DIR/index.html" .
cp "$BUILD_DIR/CNAME" .

# Optional: copy any other assets if they exist
for asset in "$BUILD_DIR"/*.css "$BUILD_DIR"/*.js "$BUILD_DIR"/*.png "$BUILD_DIR"/*.svg; do
  [ -f "$asset" ] && cp "$asset" . || true
done

# ── Commit & push ─────────────────────────────────────────────────────────────
git add -A
COMMIT_MSG="deploy: $(date -u '+%Y-%m-%d %H:%M UTC')"

if git diff --cached --quiet; then
  echo "Nothing changed — already up to date."
else
  git commit -m "$COMMIT_MSG"
  git push origin "$BRANCH"
  echo ""
  echo "✓ Deployed successfully!"
  echo "  Live at: https://$CUSTOM_DOMAIN"
  echo "  (DNS must point $CUSTOM_DOMAIN → <your-github-username>.github.io)"
fi

# ── Cleanup ───────────────────────────────────────────────────────────────────
cd /
rm -rf "$TMP_DIR"
