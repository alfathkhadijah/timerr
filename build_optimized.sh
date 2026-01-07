#!/bin/bash

echo "🚀 Building ultra-optimized Focus Space APK..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Build split APKs for different architectures (smaller individual files)
echo "📦 Building split APKs for maximum size optimization..."
flutter build apk \
  --release \
  --shrink \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --tree-shake-icons \
  --target-platform android-arm64,android-arm \
  --split-per-abi \
  --dart-define=flutter.inspector.structuredErrors=false \
  --dart-define=dart.vm.product=true

echo "✅ Optimized APKs built!"

# Check actual file sizes
echo "📍 APK Locations:"
if [ -d "build/app/outputs/flutter-apk" ]; then
    echo ""
    echo "📏 APK Sizes:"
    ls -lh build/app/outputs/flutter-apk/*.apk
    
    echo ""
    echo "🎯 Recommended APKs for distribution:"
    echo "• arm64-v8a (64-bit devices): app-arm64-v8a-release.apk"
    echo "• armeabi-v7a (32-bit devices): app-armeabi-v7a-release.apk"
    echo "• Universal (all devices): app-release.apk"
    
    # Calculate total size savings
    if [ -f "build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" ]; then
        arm64_size=$(stat -f%z build/app/outputs/flutter-apk/app-arm64-v8a-release.apk 2>/dev/null || stat -c%s build/app/outputs/flutter-apk/app-arm64-v8a-release.apk)
        arm64_mb=$((arm64_size / 1024 / 1024))
        echo ""
        echo "🎉 ARM64 APK size: ${arm64_mb}MB (optimized for most modern devices)"
    fi
else
    echo "❌ APK directory not found!"
fi