#!/bin/bash

# Development Server Script
# Starts Flutter in development mode with hot reload

set -e

echo "🔥 Starting Flutter development server..."

# Check if device is connected
DEVICES=$(flutter devices --machine | jq -r '.[].id' 2>/dev/null || flutter devices | grep -c "•" || echo "0")

if [ "$DEVICES" = "0" ]; then
    echo "📱 No devices found. Starting Chrome web version..."
    flutter run -d chrome --hot
else
    echo "📱 Found $DEVICES device(s). Starting on default device..."
    flutter run --hot
fi