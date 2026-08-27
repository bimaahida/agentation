# Agentation

Monorepo containing:

1. **npm package** (`package/`) - See `package/AGENTS.md`
2. **Website/docs** (`package/example/`) - See `package/example/AGENTS.md`

## What is Agentation?

A floating toolbar for annotating web pages and collecting structured feedback for AI coding agents.

## Development

```bash
pnpm install    # Install all workspace dependencies
pnpm dev        # Run both package watch + website dev server
pnpm build      # Build package only
```

## Releases

This fork is consumed with `npm install github:<owner>/<repo>#vX.Y.Z`, not from
the npm registry. npm cannot install a monorepo subdirectory, so it packs the
repo root - which means the build output has to be present in the tree a
consumer installs.

`dist/` stays out of branch history. `scripts/release-tag.sh` builds, then uses
`git commit-tree` against a throwaway index to create a release commit that adds
only `package/dist/index.{js,mjs,d.ts,d.mts}` on top of HEAD, and tags it. The
branch, the index, and the working tree are never touched, and sourcemaps are
left out to keep the install small.

```bash
scripts/release-tag.sh      # tags vX.Y.Z from package/package.json
git push origin vX.Y.Z      # the script prints this, it does not push for you
```

What ships is controlled by `files` in the root `package.json` plus
`package/.npmignore` (npm prefers `.npmignore` over `.gitignore`, which excludes
`dist/`). Roughly 1.3 MB across 10 files.

Consumers must pin the tag. `npm install github:<owner>/<repo>` with no ref
resolves to the default branch, which has no `dist/` and will not work.

## Important

The npm package is public. Changes to `package/src/` affect all users.
Website changes (`package/example/`) only affect agentation.dev.

## PR/Issue Approach

- Package size is critical - avoid bloat
- UI changes need extra scrutiny
- Plugins/extensions → encourage separate repos
- External binary files → never accept

## Annotations

Whenever the user brings up annotations, fetch all the pending annotations before doing anything else. And infer whether I am referencing any annotations.
