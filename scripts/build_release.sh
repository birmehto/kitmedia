#!/bin/bash

# Release Build Script
# Builds production-ready APK and iOS app

set -e

# Configuration
BUILD_NUMBER=$(date +%Y%m%d%H%M)
VERSION_NAME="1.0.0"

echo "🏗️  Building release version..."
echo "📱 Build number: $BUILD_NUMBER"
echo "🏷️  Version: $VERSION_NAME"

# Clean before building
echo "🧹 Cleaning project..."
flutter clean
flutter pub get

# Build Android APK
echo "🤖 Building Android APK..."
flutter build apk --release --build-number=$BUILD_NUMBER --build-name=$VERSION_NAME

# Build Android App Bundle (for Play Store)
echo "📦 Building Android App Bundle..."
flutter build appbundle --release --build-number=$BUILD_NUMBER --build-name=$VERSION_NAME

# Build iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Building iOS app..."
    flutter build ios --release --build-number=$BUILD_NUMBER --build-name=$VERSION_NAME
fi

# Create release directory
RELEASE_DIR="releases/v${VERSION_NAME}-${BUILD_NUMBER}"
mkdir -p "$RELEASE_DIR"

# Copy build artifacts
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    cp build/app/outputs/flutter-apk/app-release.apk "$RELEASE_DIR/"
    echo "✅ APK copied to $RELEASE_DIR/"
fi

if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    cp build/app/outputs/bundle/release/app-release.aab "$RELEASE_DIR/"
    echo "✅ App Bundle copied to $RELEASE_DIR/"
fi

echo "🎉 Release build completed!"
echo "📁 Artifacts available in: $RELEASE_DIR"