#!/bin/bash
set -e

echo "🧹 Clean build starting..."

flutter clean
flutter pub get

# Only clean Android gradle if needed
if [ -d "android" ]; then
    cd android && ./gradlew clean && cd ..
fi

echo "✅ Clean build completed!"