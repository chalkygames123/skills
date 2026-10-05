---
name: clean-up-tsconfig
description: Safely audit and remove semantically redundant TypeScript compiler options from TSConfig files, including inherited, implied, and version-dependent settings.
---

# Clean Up TSConfig

## Objective

Make each targeted TSConfig as small as possible without changing its effective behavior for the repository's supported TypeScript compiler, build commands, runtime, bundler, or editor integration. Remove only settings that are genuinely redundant; retain every setting that selects behavior, overrides an inherited setting, or deliberately pins behavior across compiler upgrades.

Treat `tsconfig.json` as JSONC unless the repository establishes otherwise. Preserve comments, formatting conventions, property order where practical, and unrelated user changes.

## Establish the Configuration Context

Before editing, determine the context for every targeted config.

- Read repository guidance and inspect package manifests, lockfiles, task scripts, CI workflows, and editor/tool configuration to find the locally installed TypeScript version and every relevant `tsc` invocation.
- Resolve each config's full `extends` chain. Base configurations load first; derived configurations override them, and relative paths are resolved from the configuration file that declares them. Treat inherited values and command-line flags as part of the effective configuration. [TypeScript TSConfig reference](https://www.typescriptlang.org/tsconfig/)
- Use the repository's own TypeScript executable. Record its version and consult its `tsc --help --all` output for the option defaults and implications that apply to that exact compiler version.
- Run `tsc -p <config> --showConfig` before editing to inspect the final configuration TypeScript reports. `--showConfig` prints the final configuration instead of building. [TypeScript compiler options](https://www.typescriptlang.org/docs/handbook/compiler-options.html)
- Identify whether the config is consumed only by `tsc` or also by a bundler, test runner, linter, framework, runtime, or editor. An option may matter to one of those consumers even when `tsc` itself can infer the same value.

Do not substitute a globally installed compiler, a web playground, a third-party option table, or assumptions from a different TypeScript release for the repository's compiler.

## Redundancy Standard

Audit every property in `compilerOptions`, not only the familiar options. A property is removable only when all of the following are true:

- Removing it leaves the effective behavior unchanged for the repository's installed TypeScript version and all relevant inherited configurations and CLI invocations.
- Its value is supplied by the compiler's current default or by another retained setting, rather than by an inherited configuration that the property currently overrides.
- It is not an intentional compatibility pin for a supported TypeScript-version range, runtime, package format, bundler, or external tool.
- It does not express an explicit opt-out such as a strict-family option set to `false` while `strict` is enabled.
- The candidate configuration passes the validation required below.

A value merely matching today's default is insufficient. Preserve it when the repository supports compiler versions with different defaults or when the explicit value communicates a supported-runtime boundary. If intent is unclear, preserve the option and report it as a possible follow-up rather than guessing.

## Evaluate Implications From the Active Compiler

Use the installed compiler's help text and the matching official documentation as the source of truth. Check implications only after resolving inheritance, because deleting a child property can reveal a different value from a base config.

Pay particular attention to these dependency groups:

- `strict` and its strict-mode family. `strict: true` enables the strict-mode family, while individual members can still be explicitly disabled; therefore, only a same-valued child setting can be redundant. [TypeScript `strict`](https://www.typescriptlang.org/tsconfig/strict.html)
- `target`, `module`, `moduleResolution`, `lib`, and `useDefineForClassFields`. These settings affect emitted syntax, built-in ambient declarations, and module lookup; determine their resolved values together rather than deleting one based on a standalone rule.
- Node and bundler module modes. Module mode can determine module resolution, package `imports` and `exports` lookup, interop behavior, and—in specific modes—the target. File extensions and the nearest `package.json` can also affect Node-mode behavior. [TypeScript module reference](https://www.typescriptlang.org/docs/handbook/modules/reference.html) [Choosing module compiler options](https://www.typescriptlang.org/docs/handbook/modules/guides/choosing-compiler-options.html)
- `resolvePackageJsonExports`, `resolvePackageJsonImports`, `esModuleInterop`, and `allowSyntheticDefaultImports`. Their defaults depend on the selected module or resolution mode. [TypeScript compiler options](https://www.typescriptlang.org/docs/handbook/compiler-options.html)
- `rewriteRelativeImportExtensions` and `allowImportingTsExtensions`; `verbatimModuleSyntax` and `isolatedModules`; and `isolatedModules` and `preserveConstEnums`. Confirm the active compiler's implications before removing either option. [TypeScript `rewriteRelativeImportExtensions`](https://www.typescriptlang.org/tsconfig/rewriteRelativeImportExtensions.html) [TypeScript `verbatimModuleSyntax`](https://www.typescriptlang.org/tsconfig/verbatimModuleSyntax.html) [TypeScript compiler options](https://www.typescriptlang.org/docs/handbook/compiler-options.html)
- `composite`, declaration emission, incremental builds, root-directory inference, project references, and file inclusion. `composite` imposes additional constraints and changes defaults, so validate build-mode behavior as well as type checking. [TypeScript `composite`](https://www.typescriptlang.org/tsconfig/composite.html)

Do not reconstruct default `lib` arrays manually. They vary by target and TypeScript release, and an explicit `lib` often intentionally excludes browser or worker globals. Likewise, do not remove `types`, `typeRoots`, `lib`, or module-resolution settings solely because the current source files do not expose a difference.

## Version Boundaries and Migrations

Determine the actual supported TypeScript range before treating a value as default. TypeScript 6.0 changed several defaults and deprecated legacy configuration choices, so an omission can change behavior across a version range even when it is redundant in one installed release. [TypeScript 6.0 release notes](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-6-0.html)

Keep deprecation migration separate from redundancy cleanup. Do not replace deprecated values, change module systems, raise `target`, alter library environments, or change resolution strategies unless the task explicitly requests that behavioral migration. Report such findings separately.

## Edit and Validate

Make the smallest possible edit set.

1. Create a baseline for each config: the effective configuration, the relevant type-check/build command output, and emitted artifacts when the project emits JavaScript or declarations.
2. Remove only candidates that meet the redundancy standard. Group dependent removals only when the retained settings still imply every removed value.
3. Re-run `tsc -p <config> --showConfig` and compare the relevant resolved values, inherited overrides, diagnostics, included files, and module behavior with the baseline.
4. Run the repository's normal validation commands. For emitting projects, also verify the normal emit or declaration build; a no-emit type check alone cannot prove that emission-related settings are redundant.
5. Revert any candidate that changes diagnostics, file inclusion, resolution, emitted output, declaration output, incremental/build-mode behavior, or another configured consumer's behavior.

## Completion Criteria

Finish only when every targeted `compilerOptions` property has been assessed against the active configuration context, every removal is proven redundant, and validation passes without unrelated changes. Leave the working tree with only the intended TSConfig edits.

Report:

- Each removed option and the retained default or implication that supplies its value.
- Each deliberately retained option that looked removable but is an override, version pin, external-tool requirement, or semantic safeguard.
- The TypeScript version, configs checked, and validation commands and results.
- Any deprecations or potential migrations discovered but intentionally left unchanged.
