# Agent Skills

Personal Agent Skills repository. Skills under `skills/` are published and installed with GitHub CLI.

## Install

```bash
gh skill install chalkygames123/skills <skill-path>
```

Built-in skills are under `skills/<skill-name>/`. Third-party skills are grouped under:

```text
skills/third-party/asd-ste100
skills/third-party/email-best-practices
skills/third-party/react-aria
```

Use the complete repository path when installing a third-party skill, for example:

```bash
gh skill install chalkygames123/skills \
    skills/third-party/react-aria \
    --dir "$HOME/.agents/skills"
```

## Sync third-party skills

The sync scripts replace the corresponding local tree with the latest upstream content. Review the diff before committing.

```bash
./scripts/sync-asd-ste100.sh
git diff -- skills/third-party/asd-ste100

./scripts/sync-email-best-practices.sh
git diff -- skills/third-party/email-best-practices

./scripts/sync-react-aria.sh
git diff -- skills/third-party/react-aria
```

The upstream sources are:

- `asd-ste100`: `https://github.com/danyuchn/asd-ste100-skill`
- `email-best-practices`: `https://github.com/resend/email-best-practices`
- `react-aria`: `https://react-aria.adobe.com` via `pnx skills add`

After reviewing a sync:

```bash
git add skills/third-party/<skill-name>
git commit -S -m 'chore: sync `<skill-name>` skill'
git push origin main
```

## Release

```bash
./scripts/publish-release.sh v1.5.0 v1.4.0
```

Pass the previous tag for every release after the first. The script validates the skills, creates a signed tag, and publishes a GitHub release with generated notes comparing the two tags.

## Validate

```bash
gh skill publish --dry-run
pnpm run fmt:check
```
