#!/bin/bash

# Savr iOS Build Script
# This script cleans extended attributes before building to avoid code signing issues

set -e  # Exit on error

echo "🧹 Cleaning extended attributes from Flutter engine..."
find /opt/homebrew/share/flutter/bin/cache/artifacts/engine/ios -type f -exec xattr -cr {} \; 2>/dev/null || true

echo "🧹 Cleaning extended attributes from project build directory..."
if [ -d "build" ]; then
  find build -type f -exec xattr -cr {} \; 2>/dev/null || true
fi

echo "🧹 Cleaning extended attributes from Pods directory..."
if [ -d "ios/Pods" ]; then
  find ios/Pods -type f -exec xattr -cr {} \; 2>/dev/null || true
fi

echo "🧹 Cleaning Flutter project..."
flutter clean

echo "📦 Getting Flutter dependencies..."
flutter pub get

echo "🔨 Installing CocoaPods..."
cd ios
pod install
cd ..

echo "🧹 Final cleanup of extended attributes..."
find /opt/homebrew/share/flutter/bin/cache/artifacts/engine/ios -type f -exec xattr -cr {} \; 2>/dev/null || true

echo "🚀 Building and running on iOS simulator..."
flutter run -d 41130867-F200-4120-834A-055EF9DF523C
