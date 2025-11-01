#!/bin/bash

# Code Quality Check Script
# Runs linting, formatting, and analysis

set -e

echo "🔍 Running code quality checks..."

# Format code
echo "✨ Formatting Dart code..."
dart format lib/ test/ --set-exit-if-changed

# Analyze code
echo "🔬 Analyzing code..."
flutter analyze

# Check for unused dependencies
echo "📦 Checking for unused dependencies..."
if command -v dart_dependency_validator &> /dev/null; then
    dart_dependency_validator
else
    echo "💡 Install dart_dependency_validator for dependency analysis:"
    echo "   dart pub global activate dart_dependency_validator"
fi

# Check for outdated packages
echo "📅 Checking for outdated packages..."
flutter pub outdated

# Custom lint rules (if using additional linters)
if grep -q "dart_code_metrics" pubspec.yaml; then
    echo "📏 Running dart_code_metrics..."
    flutter packages pub run dart_code_metrics:metrics analyze lib
fi

echo "✅ Code quality checks completed!"