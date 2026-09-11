#!/bin/sh
# Sync the React Aria skill from its generated upstream endpoint into the distribution tree.
set -eu

source_url='https://react-aria.adobe.com'
prefix='skills/third-party/react-aria'

fail() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

repo_root="$(git rev-parse --show-toplevel 2> /dev/null)" || fail 'run this command inside a Git repository'
cd "$repo_root"
[ -z "$(git status --porcelain)" ] || fail 'working tree has uncommitted or untracked changes'

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/react-aria.XXXXXX")"
trap 'rm -rf "$work_dir"' EXIT HUP INT TERM

mkdir -p "$work_dir/home" "$work_dir/config" "$work_dir/repo"
(
    cd "$work_dir/repo"
    HOME="$work_dir/home" XDG_CONFIG_HOME="$work_dir/config" pnx skills add "$source_url" --skill react-aria --agent claude-code --copy -y
)
installed="$work_dir/repo/.claude/skills/react-aria"
[ -d "$installed" ] || fail 'pnx did not create the expected React Aria skill directory'

rm -rf "$prefix"
mkdir -p "$prefix"
cp -R "$installed"/. "$prefix"/
printf 'Synced %s from %s.\n' "$prefix" "$source_url"
