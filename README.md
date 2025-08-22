# FLAST (Kaesa Flutter Starter Kit Generator)

Generate **[Kaesa Flutter Starter Kit](https://github.com/lyrihkaesa/flutter_starter_kit)** quickly with a single command.  
Cross-platform: **Windows (Git Bash / PowerShell / CMD)**, **macOS**, and **Linux**.

---

## 📦 Requirements

You need to have these installed:

- [Git](https://git-scm.com/) → required for `git clone` inside **flast**
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

```bash
flast create [projectName] [options]
```

If you don’t provide arguments, **interactive prompts** will guide you:

- Project name
- Organization (e.g., `com.example`)
- Platforms (`android`, `ios`, `web`, `windows`, `linux`, `macos`)
- Android language (`kotlin` or `java`)
- iOS language (`swift` or `objective-c`)

### Options

| Option               | #    | Description                                           |
| -------------------- | ---- | ----------------------------------------------------- |
| `--force`            | `-f` | Force overwrite if project already exists             |
| `--org`              | `-o` | Organization for your project (e.g., `com.example`)   |
| `--platforms`        | `-p` | Comma-separated list of platforms (`android,ios,web`) |
| `--android-language` | `-a` | Android language (`kotlin` or `java`)                 |
| `--ios-language`     | `-i` | iOS language (`swift` or `objective-c`)               |
| `--help`             | `-h` | Show help information                                 |
| `--version`          | `-v` | Show flast version                                    |
| `--fvm`              | `-m` | Use `.fvmrc` version in starter kit                   |
| `--no-pub`           |      | Skip pub get                                          |

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
