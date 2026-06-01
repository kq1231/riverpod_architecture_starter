---
name: flavors
description: "Add or remove flavor configurations from the starter app."
triggers:
  - add flavor
  - remove flavor
  - new flavor
  - flavor setup
  - environment
  - staging
tools_required:
  - "@Kif READ"
  - "@Kif SEARCH_AND_REPLACE"
  - "@Kif OVERWRITE_LINES"
  - "@Kif CREATE"
  - "@Kif RUN"
tags: [flavors, environments, configuration]
---

# Flavors Skill

## Overview

This project uses Flutter's built-in `--flavor` flag with a `Flavor` enum and `FlavorConfig` singleton. Two flavors exist by default: `dev` and `prod`.

## Adding a New Flavor

### 1. Update the Flavor enum

File: `lib/src/core/flavors/flavor.dart`

Add the new flavor to the enum and update all `switch` expressions:

```dart
enum Flavor {
  dev,
  staging,  // NEW
  prod;

  String get label => switch (this) {
    dev => 'DEV',
    staging => 'STAGING',  // NEW
    prod => 'PROD',
  };

  Color get seedColor => switch (this) {
    dev => Colors.orange,
    staging => Colors.teal,  // NEW
    prod => Colors.blue,
  };

  bool get isDev => this == dev || this == staging;  // Update if staging shows debug features
}
```

### 2. Update Android build.gradle.kts

File: `android/app/build.gradle.kts`

Add a `productFlavors` block inside `android`:

```kotlin
android {
    flavorDimensions += "app"
    productFlavors {
        create("dev") { dimension = "app" }
        create("staging") { dimension = "app" }  // NEW
        create("prod") { dimension = "app" }
    }
}
```

### 3. Update iOS scheme

Create a new scheme in Xcode for the staging flavor, or copy the existing dev scheme and update the `FLAVOR` preprocessor macro.

### 4. Run with the new flavor

```bash
flutter run --flavor staging
```

## Removing a Flavor

Reverse the steps:
1. Remove from the `Flavor` enum and all switch expressions
2. Remove from `android/app/build.gradle.kts` productFlavors
3. Remove the iOS scheme
4. Search for any flavor-specific code that references it

## Files to Modify

| File | What to Change |
|------|----------------|
| `lib/src/core/flavors/flavor.dart` | Enum values + switch expressions |
| `android/app/build.gradle.kts` | productFlavors block |
| `ios/Runner.xcodeproj` | Xcode schemes |

## Gotchas

- The `appFlavor` global variable is set by Flutter at compile time from `--flavor`
- `FlavorConfig.initialize()` MUST be called before any widget is built
- Android flavor names must match the enum name exactly (lowercase)
