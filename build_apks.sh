#!/bin/bash

echo "🚀 Building APKs..."
flutter build apk --split-per-abi

echo ""
echo "✨ Done! APK files:"
ls -lh build/app/outputs/flutter-apk/*.apk
