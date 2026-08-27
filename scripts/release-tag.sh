#!/usr/bin/env bash
# Tag a release whose tree carries package/dist, without putting dist on main.
#
# npm cannot install a monorepo subdirectory, so this fork is consumed by tag:
# `npm install github:<owner>/<repo>#vX.Y.Z`. That means the tag's tree has to
# contain the build output even though main keeps ignoring it.
#
# The release commit is assembled with plumbing (a throwaway index +
# commit-tree), so the working tree, the index, and the current branch are
# never touched. Only the four files a consumer actually needs are added -
# sourcemaps are left out to keep the install small.
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION=$(node -p "require('./package/package.json').version")
TAG="v$VERSION"

if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
  echo "Tag $TAG already exists. Bump the version in package/package.json first." >&2
  exit 1
fi

npm --prefix package run build

TMP_INDEX=$(mktemp -u)
trap 'rm -f "$TMP_INDEX"' EXIT

TREE=$(
  GIT_INDEX_FILE="$TMP_INDEX" bash -c '
    set -e
    git read-tree HEAD
    git add -f package/dist/index.js package/dist/index.mjs \
               package/dist/index.d.ts package/dist/index.d.mts
    git write-tree
  '
)

COMMIT=$(git commit-tree "$TREE" -p HEAD -m "release $TAG")
git tag -a "$TAG" "$COMMIT" -m "$TAG"

echo "Tagged $TAG at ${COMMIT:0:10} (branch and working tree untouched)."
echo "Push it with:  git push origin $TAG"
