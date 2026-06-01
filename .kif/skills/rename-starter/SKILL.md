---
name: rename_starter
description: "Clone and rename the starter app to create a new project from this template."
triggers:
  - rename app
  - clone project
  - new project from starter
  - rename starter
  - create from template
tools_required:
  - "@Kif RUN"
  - "@Kif READ"
  - "@Kif SEARCH_AND_REPLACE"
  - "@Kif TREE"
tags: [rename, clone, template, bootstrap]
---

# Rename Starter Skill

## Overview

Create a new project by cloning this starter and renaming everything. The rename script handles package name, app name, class names, and file references.

## Steps

### 1. Clone the starter

```bash
cp -r riverpod_architecture_starter /path/to/new_project_name
cd /path/to/new_project_name
```

### 2. Run the rename script

```bash
chmod +x scripts/rename.sh
./scripts/rename.sh com.yourcompany.newapp "New App Name"
```

### 3. What the rename script does

The script replaces:
- Package name: `com.starter.riverpod_architecture_starter` → `com.yourcompany.newapp`
- App name: `Riverpod Architecture Starter` → `New App Name`
- Folder names: `riverpod_architecture_starter` → `new_project_name`
- Import paths: all `package:riverpod_architecture_starter/` references
- Android: namespace, applicationId, MainActivity path
- iOS: bundle identifier, display name

### 4. Clean and rebuild

```bash
flutter clean
flutter pub get
dart run build_runner build
```

### 5. Verify

```bash
dart analyze lib/
flutter run --flavor dev
```

## Parameters

| Parameter | Example | Description |
|-----------|---------|-------------|
| New package name | `com.company.myapp` | Reverse domain + app name |
| New app name | `My App` | Human-readable display name |

## Gotchas

- Always run `flutter clean` after renaming
- The rename script must be run from the new project's root directory
- iOS bundle identifier must be set manually in Xcode if it differs from the package name
- Don't forget to regenerate AutoRoute files after renaming
