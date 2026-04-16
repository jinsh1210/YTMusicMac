#!/bin/bash

# YTMusicMac Release Script
# Automates: xcodegen -> xcodebuild -> hdiutil (.dmg)

set -e

APP_NAME="YTMusicMac"
SCHEME="YTMusicMac"
CONFIGURATION="Release"
BUILD_DIR="build"
APP_PATH="${BUILD_DIR}/Build/Products/${CONFIGURATION}/${APP_NAME}.app"
DMG_NAME="${APP_NAME}.dmg"

echo "Step 1: Generating project with XcodeGen..."
xcodegen generate

echo "Step 2: Building the app..."
xcodebuild -project "${APP_NAME}.xcodeproj" \
           -scheme "${SCHEME}" \
           -configuration "${CONFIGURATION}" \
           -derivedDataPath "${BUILD_DIR}" \
           clean build

echo "Step 3: Creating DMG..."
if [ -f "${DMG_NAME}" ]; then
    rm "${DMG_NAME}"
fi

hdiutil create -volname "${APP_NAME}" \
               -srcfolder "${APP_PATH}" \
               -ov -format UDZO "${DMG_NAME}"

echo "Done! ${DMG_NAME} has been created."
