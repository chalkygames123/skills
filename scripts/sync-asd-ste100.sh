#!/bin/sh
# Sync the ASD-STE100 skill from its upstream repository into the distribution tree.
set -eu

remote_name='asd-ste100-upstream'
remote_url='https://github.com/danyuchn/asd-ste100-skill.git'
upstream_branch='master'
prefix='skills/third-party/asd-ste100'

fail() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

repo_root="$(git rev-parse --show-toplevel 2> /dev/null)" || fail 'run this command inside a Git repository'
cd "$repo_root"
[ -z "$(git status --porcelain)" ] || fail 'working tree has uncommitted or untracked changes'

if ! git config --get "remote.$remote_name.url" > /dev/null 2>&1; then
    git remote add "$remote_name" "$remote_url"
fi
git fetch "$remote_name" "$upstream_branch"

source_commit="$(git rev-parse "$remote_name/$upstream_branch")"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/asd-ste100.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

git archive "$source_commit" | tar -x -C "$tmp_dir"
rm -rf "$prefix"
mkdir -p "$prefix"
cp -R "$tmp_dir"/. "$prefix"/
printf 'Synced %s from %s at %s.\n' "$prefix" "$remote_url" "$source_commit"
