# Releasing gvm2

This document describes how to create a new release of gvm2.

## Version Numbering

gvm2 follows [Semantic Versioning](https://semver.org/):

- **MAJOR** (X.0.0): Breaking changes to CLI interface or behavior
- **MINOR** (0.X.0): New features, backward-compatible
- **PATCH** (0.0.X): Bug fixes, backward-compatible

Use conventional commit messages to help determine the appropriate bump:

| Commit prefix | Version bump |
|---------------|--------------|
| `fix:` | Patch |
| `feat:` | Minor |
| `feat!:` or `BREAKING CHANGE:` | Major |

## Release Process

### 1. Determine the version

Review commits since the last tag to determine the appropriate version bump:

```bash
git log $(git describe --tags --abbrev=0)..HEAD --oneline
```

### 2. Update VERSION file

```bash
echo "1.2.3" > VERSION
```

### 3. Update ChangeLog

Add a new section at the top of `ChangeLog` with the version and today's date:

```markdown
## [1.2.3] - YYYY-MM-DD

### Added
- New feature X

### Fixed
- Bug fix Y

### Changed
- Behavior change Z
```

Use these categories as appropriate:
- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Features that will be removed
- **Removed**: Features that were removed
- **Fixed**: Bug fixes
- **Security**: Security-related changes

### 4. Commit the release

```bash
git add VERSION ChangeLog
git commit -m "chore: release v1.2.3"
git push origin master
```

### 5. Create and push the tag

```bash
git tag v1.2.3
git push origin v1.2.3
```

This triggers the release workflow, which:
- Validates the tag matches the VERSION file
- Extracts release notes from ChangeLog
- Creates a GitHub Release

### 6. Verify the release

Check the [Releases page](https://github.com/brianrobt/gvm2/releases) to confirm
the release was created correctly.

## Pre-release Versions

For release candidates or beta versions, use suffixes:

```bash
echo "1.3.0-rc.1" > VERSION
git tag v1.3.0-rc.1
```

Pre-releases are automatically marked as such on GitHub when the tag contains
`-rc`, `-beta`, or `-alpha`.

## Hotfix Releases

For urgent fixes to a previous release:

1. Create a branch from the release tag: `git checkout -b hotfix/1.2.4 v1.2.3`
2. Apply the fix
3. Follow the normal release process, bumping the patch version
4. Merge the fix back to master if applicable
