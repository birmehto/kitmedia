#!/bin/bash
set -e

echo "🔍 Running code quality checks..."

# Essential checks only
dart format lib/ --set-exit-if-changed
flutter analyze

echo "✅ Code quality checks completed!"