#!/usr/bin/env bash
set -euo pipefail

REPO="TDesktop-x64/tdesktop"

echo "==> Fetching latest release tag..."
TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['tag_name'])")

echo "==> Cloning upstream ($TAG) with submodules..."
rm -rf upstream/
git clone --recurse-submodules --shallow-submodules --depth 1 \
  --branch "$TAG" "https://github.com/$REPO.git" upstream/

echo "==> Copying over current tree..."
rsync -a upstream/ ./ --exclude='.git/'

echo "==> De-submoduling: removing gitlinks so submodule dirs become regular directories..."
rm -f .gitmodules
git submodule status | awk '{print $2}' | while read path; do
  git rm --cached "$path" 2>/dev/null || true
done

echo "==> Cleaning up..."
rm -rf upstream/

echo "==> Done."
