#!/bin/bash
set -e

# Get version from pubspec.yaml
VERSION_NAME=$(grep '^version:' pubspec.yaml | cut -d' ' -f2 | cut -d'+' -f1)
BUILD_NUMBER=$(date +%Y%m%d%H%M)

echo "🏗️ Building release v$VERSION_NAME+$BUILD_NUMBER"

flutter clean && flutter pub get

# Build Android only (iOS removed - not needed for most projects)
flutter build apk --release --build-number="$BUILD_NUMBER" --build-name="$VERSION_NAME"
# shellcheck disable=SC2086
flutter build appbundle --release --build-number=$BUILD_NUMBER --build-name=$VERSION_NAME

echo "✅ Release build completed!"