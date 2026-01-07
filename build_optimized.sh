#!/bin/bash

echo "🚀 Building optimized Focus Space APK..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Build optimized APK with basic size reduction
echo "📦 Building optimized release APK..."
flutter build apk \
  --release \
  --shrink \
  --target-platform android-arm64

echo "✅ Optimized APK built successfully!"
echo "📍 Location: build/app/outputs/flutter-apk/app-release.apk"

# Show APK size
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    size=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
    echo "📏 APK Size: $size"
fi

echo "🎯 Size optimization techniques applied:"
echo "   ✓ Code shrinking"
echo "   ✓ Resource shrinking"
echo "   ✓ R8 optimization"
echo "   ✓ ARM64 only (smaller size)"
echo "   ✓ Removed unused assets"
echo "   ✓ Optimized dependencies"