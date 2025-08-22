## 0.1.0

**Added:**

- `flast create` command to generate Flutter starter kit projects with full options:

  - Interactive prompts for project name, organization, platforms, Android/iOS language.
  - Supports starter kit version/tag (`--kit-version`) and custom repo (`--kit-repo`).
  - Optional flags: `--force`, `--fvm`, `--no-pub`, `--force-download`, `--verbose`, `--debug`.

- `flast new` command for simpler project creation with fewer options:

  - Uses sensible defaults for Android/iOS language and starter kit.
  - Supports `--force`, `--org`, `--platforms`, `--fvm`, `--no-pub`, `--force-download`, `--verbose`, `--debug`.

- Remove require `git`: flast don't use `git clone` and `git init` again.
- Automatic starter kit download with caching
- FVM integration to use Flutter version from `.fvmrc`.
- Logging and progress output with optional verbose/debug mode.

**Notes:**

- Git Bash on Windows may freeze interactive prompts if called via `.bat`; use PowerShell or CMD instead.
- Default starter kit version is `main` if no tag is specified.

## 0.0.5

- Refactored CLI code for better readability and maintainability.
- Added support for `--help` and `--version` flags across commands.
- Internal changes only, no breaking changes.

## 0.0.4

- Automatic setup dart fvm
- mason get
- build freezed

## 0.0.3

- Fix (Windows): Only work in powershell

## 0.0.2

- Fix: `flast as globally activated doesn't support Dart 3.7.0.`

## 0.0.1

- Initial version.
