#!/bin/bash

# Script để tạo GitHub Release và upload APK
# Sử dụng: ./release.sh v2.1.1

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "❌ Vui lòng nhập version tag (ví dụ: ./release.sh v2.1.1)"
    exit 1
fi

echo "🚀 Creating GitHub Release $VERSION..."

# Tạo release
gh release create "$VERSION" \
    build/app/outputs/flutter-apk/app-arm64-v8a-release.apk \
    build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk \
    build/app/outputs/flutter-apk/app-x86_64-release.apk \
    --title "ManyDrive $VERSION" \
    --notes "## ManyDrive Release $VERSION

### APK Files
- **arm64-v8a**: For modern 64-bit ARM devices (recommended for most devices)
- **armeabi-v7a**: For older 32-bit ARM devices
- **x86_64**: For x86 64-bit devices (emulators, tablets)

### Installation
Download the appropriate APK for your device architecture and install it."

echo "✅ Done! Release created at: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/releases/tag/$VERSION"
