#!/bin/sh
# Validate skills, create a signed tag at the default branch HEAD, and publish a GitHub release with explicitly bounded generated release notes.
set -eu

usage() {
    printf 'Usage: %s <tag> [previous-tag]\n' "${0##*/}" >&2
    printf '\n' >&2
    printf 'Examples:\n' >&2
    printf '  %s v1.0.0\n' "${0##*/}" >&2
    printf '  %s v1.1.0 v1.0.0\n' "${0##*/}" >&2
    exit 64
}

fail() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

[ "$#" -ge 1 ] && [ "$#" -le 2 ] || usage
tag="$1"
previous_tag="${2-}"

repo_root="$(git rev-parse --show-toplevel 2> /dev/null)" || fail 'run this command inside a Git repository'
cd "$repo_root"

[ -z "$(git status --porcelain)" ] || fail 'working tree has uncommitted or untracked changes'

repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)" || fail 'cannot determine the GitHub repository'
default_branch="$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)" || fail 'cannot determine the default branch'

git fetch origin "$default_branch" --tags
head_commit="$(git rev-parse HEAD)"
default_branch_commit="$(git rev-parse "origin/$default_branch")"
[ "$head_commit" = "$default_branch_commit" ] || fail "HEAD must equal origin/$default_branch before releasing"

git rev-parse --verify --quiet "refs/tags/$tag" > /dev/null && fail "local tag already exists: $tag"
git ls-remote --exit-code --tags origin "refs/tags/$tag" > /dev/null 2>&1 && fail "remote tag already exists: $tag"
gh release view "$tag" --repo "$repo" > /dev/null 2>&1 && fail "release already exists: $tag"

if [ -n "$previous_tag" ]; then
    git ls-remote --exit-code --tags origin "refs/tags/$previous_tag" > /dev/null 2>&1 || fail "previous tag does not exist on origin: $previous_tag"
    gh release view "$previous_tag" --repo "$repo" > /dev/null 2>&1 || fail "previous release does not exist: $previous_tag"
else
    release_count="$(gh api "repos/$repo/releases?per_page=1" --jq 'length')"
    [ "$release_count" -eq 0 ] || fail 'specify <previous-tag> when releases already exist'
fi

# Validation only: release creation is deliberately handled by gh release create.
gh skill publish --dry-run

# Use the repository's configured signing program and signing key.
git tag -s "$tag" -m "Release $tag"
git push origin "refs/tags/$tag"

if [ -n "$previous_tag" ]; then
    gh release create "$tag" \
        --repo "$repo" \
        --verify-tag \
        --title "$tag" \
        --generate-notes \
        --notes-start-tag "$previous_tag"
else
    gh release create "$tag" \
        --repo "$repo" \
        --verify-tag \
        --title "$tag" \
        --generate-notes
fi
