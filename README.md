# FLAST (Kaesa Flutter Starter Kit Generator)

Generate **[Kaesa Flutter Starter Kit](https://github.com/lyrihkaesa/flutter_starter_kit)** quickly with a single command.
Cross-platform: **Windows (Git Bash / PowerShell / CMD)**, **macOS**, and **Linux**.

---

## 📦 Requirements

You need to have these installed:

- [Git](https://git-scm.com/) → required for `git clone` inside **flast**
- [Mason](https://pub.dev/packages/mason_cli) → required for templating

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

Show help:

```bash
flast --help
```

---

## 🛠️ Usage

Create a new Flutter starter kit project:

```bash
flast create
```

---

## 💡 Aliases (Optional for Git Bash on Windows)

If `mason` or `flast` cannot be called directly in **Git Bash**, add these to `~/.bashrc`:

```bash
alias mason="/c/Users/<username>/AppData/Local/Pub/Cache/bin/mason.bat"
alias flast="/c/Users/<username>/AppData/Local/Pub/Cache/bin/flast.bat"
```

Replace `<username>` with your Windows username.
Or just use **PowerShell / CMD** directly.

---

## 📖 Example Workflow

```bash
# Check tools
git --version
mason --version
flast --version

# See all available options
flast --help

# Create a new project
flast create
```
