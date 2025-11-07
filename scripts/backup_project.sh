#!/bin/bash

# Project Backup Script
# Creates a backup of the project excluding build files

set -e

# Configuration
BACKUP_DIR="backups"
PROJECT_NAME=$(basename "$PWD")
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="${PROJECT_NAME}_backup_${TIMESTAMP}"

echo "💾 Creating project backup..."

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Create temporary directory for backup
TEMP_BACKUP="/tmp/$BACKUP_NAME"
mkdir -p "$TEMP_BACKUP"

# Copy project files (excluding build artifacts)
echo "📁 Copying project files..."
rsync -av \
    --exclude='.dart_tool/' \
    --exclude='build/' \
    --exclude='.gradle/' \
    --exclude='android/.gradle/' \
    --exclude='android/app/build/' \
    --exclude='ios/Pods/' \
    --exclude='ios/build/' \
    --exclude='.idea/' \
    --exclude='*.iml' \
    --exclude='.DS_Store' \
    --exclude='node_modules/' \
    --exclude='*.log' \
    . "$TEMP_BACKUP/"

# Create compressed archive
echo "🗜️  Compressing backup..."
cd /tmp
tar -czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"

# Move to backup directory
mv "${BACKUP_NAME}.tar.gz" "$PWD/$BACKUP_DIR/"

# Cleanup
rm -rf "$TEMP_BACKUP"

echo "✅ Backup created: $BACKUP_DIR/${BACKUP_NAME}.tar.gz"

# Keep only last 5 backups
cd "$PWD/$BACKUP_DIR"
# shellcheck disable=SC2012
ls -t "${PROJECT_NAME}"_backup_*.tar.gz | tail -n +6 | xargs -r rm

echo "🧹 Old backups cleaned up (keeping last 5)"