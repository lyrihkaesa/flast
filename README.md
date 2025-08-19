# FKIT (Kaesa Flutter Stater Kit Generator)

Ini digunakan untuk mempermudah dalam generate kaesa flutter stater kit.

---

Jika anda menggunakan fvm pastikan anda masukan flutter ke Environtment Windows.
Jadi pathnya kira-kira:

```txt
C:\Users\<username>\fvm\versions\3.32.5\bin
```

Setelah itu anda pastikan dart bisa dijalankan:

```bash
dart --version
```

Setelah itu anda bisa install flast

```bash
dart pub global activate flast
```

Anda bisa menjalankan flast:

```bash
flast create
```

> Jika anda pengguna windows pastkan gunakan powershell/cmd karena git bash sepertinya tidak bisa saya kurang tahu kenapa tidak bisa, tunggu solusi update nanti.

## Dev

```bash
fvm dart pub global activate --source path .
```

```bash
fvm dart run flast create
```

```bash
dart pub global deactivate flast && dart pub global activate --source path .
```

## Publish

```bash
fvm dart pub publish --dry-run
```

```bash
fvm dart pub publish
```
