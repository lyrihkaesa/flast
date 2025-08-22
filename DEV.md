# FLAST (Catatan Kaesa)

Ini hanya catatan cara publish dan testing development

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

Sebelum publish harap update dulu `version.dart`

```bash
dart run tool/generate_version.dart
```

```bash
fvm dart pub publish --dry-run
```

```bash
fvm dart pub publish
```
