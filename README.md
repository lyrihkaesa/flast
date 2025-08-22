# FLAST (Kaesa Flutter Starter Kit Generator)

Generate **[Kaesa Flutter Starter Kit](https://github.com/lyrihkaesa/flutter_starter_kit)** quickly with a single command.  
Cross-platform: **Windows (Git Bash / PowerShell / CMD)**, **macOS**, and **Linux**.

---

## 📦 Requirements

You need to have these installed:

- [Mason](https://pub.dev/packages/mason_cli) → required for templating
- [Dart](https://dart.dev/get-dart)

Install Mason if you don’t have it yet:

```bash
dart pub global activate mason_cli
```

Check version:

```bash
mason --version
```

---

## 🚀 Installation

Activate **flast** globally:

```bash
dart pub global activate flast
```

Check version:

```bash
flast --version
```

Show global help:

```bash
flast --help
```

---

## 🛠️ Usage

### Create a new Flutter starter kit project

Use **`create`** for full options or **`new`** for a simpler, faster setup:

```bash
# Full options (interactive prompts if omitted)
flast create [projectName] [options]

# Simple creation (fewer options, defaults applied)
flast new [projectName] [options]
```

If you don’t provide arguments, **interactive prompts** will guide you:

- Project name
- Organization (e.g., `com.example`)
- Platforms (`android`, `ios`, `web`, `windows`, `linux`, `macos`)
- Android language (`kotlin` or `java`)
- iOS language (`swift` or `objective-c`)

> Note: new skips prompts for Android/iOS language and starter kit version/repo; defaults are used.

### Options

| Command         | Option               | #    | Description                                           |
| --------------- | -------------------- | ---- | ----------------------------------------------------- |
| `create`, `new` | `--force`            | `-f` | Force overwrite if project already exists             |
| `create`, `new` | `--org`              | `-o` | Organization for your project (e.g., `com.example`)   |
| `create`, `new` | `--platforms`        | `-p` | Comma-separated list of platforms (`android,ios,web`) |
| `create`        | `--android-language` | `-a` | Android language (`kotlin` or `java`)                 |
| `create`        | `--ios-language`     | `-i` | iOS language (`swift` or `objective-c`)               |
| `create`, `new` | `--help`             | `-h` | Show help information                                 |
| `create`, `new` | `--version`          | `-v` | Show flast version                                    |
| `create`, `new` | `--fvm`              | `-m` | Use `.fvmrc` version in starter kit                   |
| `create`, `new` | `--no-pub`           |      | Skip pub get                                          |
| `create`        | `--kit-version`      | `-t` | Starter kit version/tag (e.g., 3.0.1)                 |
| `create`        | `--kit-repo`         | `-r` | Starter kit repo URL                                  |
| `create`, `new` | `--force-download`   | `-d` | Force download starter kit even if cached             |
| `create`, `new` | `--verbose`          |      | Verbose Output                                        |
| `create`, `new` | `--debug`            | `-D` | Verbose Output                                        |

---

## 💡 Windows Git Bash Note

If `flast` is called via `.bat` in Git Bash, **interactive prompts may freeze**.
Use **PowerShell or CMD** for a smooth experience.

Optional aliases for Git Bash:

```bash
alias mason="/c/Users/<username>/AppData/Local/Pub/Cache/bin/mason.bat"
alias flast="/c/Users/<username>/AppData/Local/Pub/Cache/bin/flast.bat"
```

Replace `<username>` with your Windows username.

---

## 📖 Example Workflow

```bash
# Check tools
git --version
mason --version
flast --version

# See global help
flast --help

# Create project interactively
flast create

# Create project with options
flast create my_app --org com.lyrihkaesa --platforms android,ios,web --android-language kotlin --ios-language swift --force

# Create project with fvm and no pub
flast create my_app --org com.lyrihkaesa --platforms android,ios,web --android-language kotlin --ios-language swift --force --no-pub --fvm
```

---

## ✅ Next Steps After Creation

```bash
cd <projectName>
mason get
dart run build_runner build --delete-conflicting-outputs
flutter run
```
