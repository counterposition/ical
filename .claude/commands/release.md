Create a new release for the `counterposition/ical` fork.

## Version policy

Fork releases start at `v0.100.0` and use normal pre-1.0 semantic versioning:

- **MINOR** (`v0.X.0`): new features or breaking changes
- **PATCH** (`v0.X.Y`): fixes, documentation, maintenance, or dependency updates

The `v0.100+` range distinguishes fork releases from upstream's `v0.12.x`
line while keeping the module compatible with Go's unsuffixed import path.
Never retag an upstream version as a fork release.

## Step 1: Analyze changes

Use the latest fork release as the comparison point. For the first fork
release, use the synchronized upstream `v0.12.2` baseline:

```bash
git tag --sort=-v:refname | head
git log <previous-tag>..HEAD --oneline
git diff <previous-tag>..HEAD --stat
```

Read the commits and propose a version. Confirm it before publishing unless the
version was already specified explicitly.

## Step 2: Validate locally

```bash
make check-module
make test
make lint
make release VERSION=v<VERSION>
```

Confirm that `bin/` contains:

- `ical-darwin-arm64.tar.gz`
- `ical-darwin-amd64.tar.gz`
- `SHA256SUMS`

Extract the native archive and verify that `ical version` reports the exact
release version.

## Step 3: Push main before tagging

The release tag must point to a commit already present on remote `main`:

```bash
git push origin main
git tag v<VERSION>
git push origin v<VERSION>
```

Pushing a valid `v0.100+` tag triggers `.github/workflows/release.yml`. The
workflow repeats module validation, tests, lint, dual-architecture builds,
archive checks, and checksum verification before publishing the GitHub release.

Never tag an unpushed commit. Otherwise the release can contain code that is
not reachable from remote `main`.

## Step 4: Verify publication

Wait for the Release workflow and verify:

```bash
gh run list --workflow Release --limit 1
gh release view v<VERSION>
```

The release must be marked latest and include all three expected assets. Then
verify both supported installation paths from clean temporary locations:

```bash
go install github.com/counterposition/ical/cmd/ical@v<VERSION>
curl -fsSL https://raw.githubusercontent.com/counterposition/ical/main/scripts/install.sh | bash
```

## Release notes

The workflow prepends fork-specific installation instructions and asks GitHub
to generate the changelog since the previous fork release. For the first fork
release it starts at upstream `v0.12.2`.

Release notes should remain user-facing:

1. Lead with breaking changes when present.
2. Group changes by capability, not by file.
3. Include examples for new commands or flags.
4. Mention new environment variables and flags.
5. Avoid internal implementation details unless they affect users.
