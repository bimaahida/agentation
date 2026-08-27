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
the npm registry. npm cannot install a monorepo subdirectory, so the tag cannot
just point at a branch commit.

`scripts/release-tag.sh` builds, then assembles a tree from scratch with the
package at its root - `package.json`, `dist/`, README, LICENSE, nothing else -
and tags a commit carrying that tree. Consumers get `node_modules/agentation`
directly: no symlink, no source, no build at install time. GitHub's source
archive for the tag is the same lean tree. `devDependencies` and `scripts` are
stripped from the released `package.json`, because npm installs a git
dependency's devDependencies whenever it has to run `prepare` - that would pull
a second copy of React into the consumer's tree and break hooks.

The release commit keeps the branch commit as its parent for traceability but
shares none of its tree, so `dist/` stays out of branch history.

```bash
scripts/release-tag.sh      # tags vX.Y.Z from package/package.json
git push origin vX.Y.Z      # the script prints this, it does not push for you
```

Consumers must pin the tag. `npm install github:<owner>/<repo>` with no ref
resolves to the default branch, which has no build output.

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
