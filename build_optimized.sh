#!/bin/bash

echo "🚀 Building highly optimized Focus Space APK..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Build with maximum optimization
echo "📦 Building with maximum optimization..."
flutter build apk \
  --release \
  --shrink \
  --target-platform android-arm64 \
  --tree-shake-icons \
  --dart-define=flutter.inspector.structuredErrors=false

echo "✅ Optimized APK built!"

# Check actual file size
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "📍 Location: build/app/outputs/flutter-apk/app-release.apk"
    size=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
    echo "📏 Actual APK Size: $size"
    
    # Get detailed size info
    ls -lh build/app/outputs/flutter-apk/app-release.apk
    
    # Analyze APK contents
    echo ""
    echo "🔍 Analyzing APK contents..."
    if command -v unzip &> /dev/null; then
        echo "Top 10 largest files in APK:"
        unzip -l build/app/outputs/flutter-apk/app-release.apk | sort -k1 -nr | head -15
    fi
else
    echo "❌ APK not found!"
fi