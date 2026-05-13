#!/bin/bash
# scripts/take_screenshots.sh — iOS App Store Screenshot Automation via Simulator
# Run from the project root: bash scripts/take_screenshots.sh
set -euo pipefail

APP_BUNDLE="$(grep 'PRODUCT_BUNDLE_IDENTIFIER' ios/Runner.xcodeproj/project.pbxproj | head -1 | sed 's/.*= //;s/;//;s/ //g')" || true
APP_BUNDLE="${APP_BUNDLE:-com.spencersmith.restChooser}"

BUILD_DIR="build/ios/iphonesimulator"
OUTPUT_DIR="screenshots/store"
mkdir -p "$OUTPUT_DIR"

# Device configs: name suffix : simulator device type : OS version
DEVICES=(
    "6.7inch:iPhone 16 Pro Max"
    "6.1inch:iPhone 16 Pro"
    "5.5inch:iPhone 8 Plus"
)

echo "==> Building iOS Simulator bundle..."
flutter build ios --simulator

echo "==> Cleaning up output dir..."
rm -f "$OUTPUT_DIR"/*.png

for spec in "${DEVICES[@]}"; do
    SUFFIX="${spec%%:*}"
    DEVICE="${spec#*:}"
    echo "==> Booting simulator: $DEVICE"
    xcrun simctl boot "$DEVICE" 2>/dev/null || true
    xcrun simctl shutdown "$DEVICE" 2>/dev/null || true
    xcrun simctl boot "$DEVICE"
    sleep 2

    echo "    Installing app..."
    xcrun simctl install "$DEVICE" "$BUILD_DIR/Runner.app"

    echo "    Launching app..."
    xcrun simctl launch "$DEVICE" "$APP_BUNDLE" || true
    sleep 5

    echo "    Capturing light screenshot..."
    xcrun simctl io "$DEVICE" screenshot "$OUTPUT_DIR/${SUFFIX}_light.png"

    echo "    Switching to dark mode..."
    xcrun simctl ui "$DEVICE" appearance dark
    sleep 1
    echo "    Capturing dark screenshot..."
    xcrun simctl io "$DEVICE" screenshot "$OUTPUT_DIR/${SUFFIX}_dark.png"

    echo "    Resetting to light mode..."
    xcrun simctl ui "$DEVICE" appearance light

    echo "    Shutting down simulator..."
    xcrun simctl shutdown "$DEVICE"
done

echo "==> Done. Screenshots saved to $OUTPUT_DIR"
ls -la "$OUTPUT_DIR"
