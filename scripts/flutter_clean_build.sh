#!/bin/bash

# Flutter Clean Build Script
# Performs a complete clean and rebuild of the Flutter project

set -e

echo "🧹 Starting Flutter clean build process..."

# Clean Flutter build cache
echo "📱 Cleaning Flutter build cache..."
flutter clean

# Remove pub cache lock
echo "🔓 Removing pubspec.lock..."
rm -f pubspec.lock

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Clean and rebuild for Android
if [ -d "android" ]; then
    echo "🤖 Cleaning Android build..."
    cd android
    ./gradlew clean
    cd ..
fi

# Clean iOS build (if on macOS)
if [ -d "ios" ] && [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Cleaning iOS build..."
    cd ios
    rm -rf Pods
    rm -f Podfile.lock
    pod install
    cd ..
fi

# Rebuild Flutter
echo "🔨 Building Flutter app..."
flutter build apk --debug

echo "✅ Clean build completed successfully!"