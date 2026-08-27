#!/usr/bin/env bash
# Tag a release whose tree is the built package and nothing else.
#
# npm cannot install a monorepo subdirectory, so this fork is consumed by tag:
# `npm install github:<owner>/<repo>#vX.Y.Z`. The tag's tree is assembled from
# scratch with the package at its root, so a consumer gets node_modules/agentation
# directly - no symlink, no source, no build step at install time. GitHub's source
# archive for the tag is the same lean tree.
#
# The release commit keeps the branch commit as its parent for traceability, but
# shares none of its tree. The branch, the index, and the working tree are never
# touched.
set -euo pipefail

REPO=$(cd "$(dirname "$0")/.." && pwd)
cd "$REPO"

VERSION=$(node -p "require('./package/package.json').version")
TAG="v$VERSION"

if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
  echo "Tag $TAG already exists. Bump the version in package/package.json first." >&2
  exit 1
fi

npm --prefix package run build

STAGE=$(mktemp -d)
IDX=$(mktemp -u)
trap 'rm -rf "$STAGE" "$IDX"' EXIT

mkdir -p "$STAGE/dist"
cp package/dist/index.js package/dist/index.mjs \
   package/dist/index.d.ts package/dist/index.d.mts "$STAGE/dist/"
cp package/README.md package/LICENSE "$STAGE/"

# Drop devDependencies and scripts. npm installs a git dependency's
# devDependencies whenever it has to run `prepare`, which would pull a second
# copy of React into the consumer's tree and break hooks.
node -e '
const pkg = require("./package/package.json");
delete pkg.devDependencies;
delete pkg.scripts;
require("fs").writeFileSync(process.argv[1] + "/package.json", JSON.stringify(pkg, null, 2) + "\n");
' "$STAGE"

export GIT_INDEX_FILE="$IDX"
git --git-dir="$REPO/.git" --work-tree="$STAGE" add -A -f "$STAGE"
TREE=$(git --git-dir="$REPO/.git" --work-tree="$STAGE" write-tree)
unset GIT_INDEX_FILE

COMMIT=$(git commit-tree "$TREE" -p HEAD -m "release $TAG

Build output only. Source: $(git rev-parse --short HEAD)")
git tag -a "$TAG" "$COMMIT" -m "$TAG"

echo "Tagged $TAG at ${COMMIT:0:10} (branch and working tree untouched)."
git ls-tree -r --name-only "$TAG" | sed 's/^/  /'
echo "Push it with:  git push origin $TAG"
