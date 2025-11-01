#!/bin/bash

# Development Environment Setup Script
# Sets up the development environment and checks dependencies

set -e

echo "🚀 Setting up development environment..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check Flutter doctor
echo "🩺 Running Flutter doctor..."
flutter doctor

# Install dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

# Generate code if needed
if [ -f "build_runner.yaml" ] || grep -q "build_runner" pubspec.yaml; then
    echo "🔧 Running code generation..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
fi

# Check for Android SDK
if [ -d "$ANDROID_HOME" ]; then
    echo "✅ Android SDK found at $ANDROID_HOME"
else
    echo "⚠️  Android SDK not found. Set ANDROID_HOME environment variable."
fi

# Create useful directories
mkdir -p logs
mkdir -p temp

echo "✅ Development environment setup completed!"
echo "💡 Run './scripts/run_dev.sh' to start development server"