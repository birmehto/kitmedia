#!/bin/bash
set -e

# Version upgrade script - increments version and creates git tag

CURRENT_VERSION=$(grep '^version:' pubspec.yaml | cut -d' ' -f2 | cut -d'+' -f1)
echo "Current version: $CURRENT_VERSION"

# Parse version parts
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Default to patch increment
INCREMENT_TYPE=${1:-patch}

case $INCREMENT_TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo "Usage: $0 [major|minor|patch]"
        echo "Default: patch"
        exit 1
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
BUILD_NUMBER=$(date +%Y%m%d%H%M)

echo "New version: $NEW_VERSION+$BUILD_NUMBER"

# Update pubspec.yaml
sed -i "s/^version: .*/version: $NEW_VERSION+$BUILD_NUMBER/" pubspec.yaml

# Commit and tag
git add pubspec.yaml
git commit -m "chore: bump version to $NEW_VERSION"
git tag "v$NEW_VERSION"

echo "✅ Version upgraded to $NEW_VERSION"
echo "🏷️  Tagged as v$NEW_VERSION"
echo "📤 Push with: git push origin main --tags"