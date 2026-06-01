#!/bin/bash
# Rename script for the Riverpod Architecture Starter app.
# Usage: ./rename.sh <new_package_name> <new_app_name>
# Example: ./rename.sh com.mycompany.myapp "My App"

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <new_package_name> <new_app_name>"
  echo "Example: $0 com.mycompany.myapp \"My App\""
  exit 1
fi

NEW_PACKAGE="$1"
NEW_APP_NAME="$2"
OLD_PACKAGE="com.starter.riverpod_architecture_starter"
OLD_APP_NAME="Riverpod Architecture Starter"
PROJECT_DIR="$(pwd)"

echo "Renaming:"
echo "  Package: $OLD_PACKAGE → $NEW_PACKAGE"
echo "  App name: $OLD_APP_NAME → $NEW_APP_NAME"
echo ""

# Replace package name in all Dart files
echo "Updating Dart imports..."
find "$PROJECT_DIR/lib" -name "*.dart" -exec sed -i '' "s|package:riverpod_architecture_starter/|package:$(echo "$NEW_PACKAGE" | tr '.' '_' | tr '[:upper:]' '[:lower:]')/|g" {} +

# Replace app display name
echo "Updating app display name..."
find "$PROJECT_DIR/lib" -name "*.dart" -exec sed -i '' "s|$OLD_APP_NAME|$NEW_APP_NAME|g" {} +

# Android: namespace and applicationId
echo "Updating Android config..."
if [ -f "$PROJECT_DIR/android/app/build.gradle.kts" ]; then
  sed -i '' "s|$OLD_PACKAGE|$NEW_PACKAGE|g" "$PROJECT_DIR/android/app/build.gradle.kts"
  sed -i '' "s|$OLD_APP_NAME|$NEW_APP_NAME|g" "$PROJECT_DIR/android/app/src/main/AndroidManifest.xml"
fi

# Android: move MainActivity to new package path
OLD_ANDROID_PATH="$PROJECT_DIR/android/app/src/main/kotlin/$(echo "$OLD_PACKAGE" | tr '.' '/')"
NEW_ANDROID_PATH="$PROJECT_DIR/android/app/src/main/kotlin/$(echo "$NEW_PACKAGE" | tr '.' '/')"
if [ -d "$OLD_ANDROID_PATH" ]; then
  echo "Moving Android MainActivity..."
  mkdir -p "$NEW_ANDROID_PATH"
  mv "$OLD_ANDROID_PATH"/*.kt "$NEW_ANDROID_PATH/" 2>/dev/null || true
  find "$NEW_ANDROID_PATH" -name "*.kt" -exec sed -i '' "s|package $OLD_PACKAGE|package $NEW_PACKAGE|g" {} +
  rm -rf "$OLD_ANDROID_PATH"
fi

# iOS: bundle identifier and display name
echo "Updating iOS config..."
if [ -f "$PROJECT_DIR/ios/Runner/Info.plist" ]; then
  sed -i '' "s|$OLD_APP_NAME|$NEW_APP_NAME|g" "$PROJECT_DIR/ios/Runner/Info.plist"
fi

echo ""
echo "✅ Rename complete! Now run:"
echo "  flutter clean"
echo "  flutter pub get"
echo "  dart run build_runner build"
echo "  dart analyze lib/"
