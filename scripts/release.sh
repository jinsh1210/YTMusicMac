#!/bin/bash

# YTMusicMac Release Script
# Automates: [xcodegen] -> xcodebuild -> hdiutil (.dmg)

set -e

# 스크립트 위치와 무관하게 항상 프로젝트 루트에서 실행
cd "$(dirname "$0")/.."

APP_NAME="YTMusicMac"
SCHEME="YTMusicMac"
CONFIGURATION="Release"
BUILD_DIR="build"
APP_PATH="${BUILD_DIR}/Build/Products/${CONFIGURATION}/${APP_NAME}.app"
DMG_NAME="${APP_NAME}.dmg"
STAGING_DIR="/tmp/${APP_NAME}-dmg-staging"

# Step 1: XcodeGen (installed 경우에만 실행)
if command -v xcodegen &> /dev/null; then
    echo "Step 1: Generating project with XcodeGen..."
    xcodegen generate
else
    echo "Step 1: XcodeGen not installed — using existing project file."
fi

# Step 2: Build
echo "Step 2: Building the app..."
xcodebuild -project "${APP_NAME}.xcodeproj" \
           -scheme "${SCHEME}" \
           -configuration "${CONFIGURATION}" \
           -derivedDataPath "${BUILD_DIR}" \
           clean build | grep -E "^(Build|error:|warning:|\\*\\*)" || true

if [ ! -d "${APP_PATH}" ]; then
    echo "Error: Build failed — ${APP_PATH} not found."
    exit 1
fi

# Step 3: DMG 생성 (Applications 심볼릭 링크 포함)
echo "Step 3: Creating DMG..."
rm -rf "${STAGING_DIR}"
mkdir -p "${STAGING_DIR}"
cp -R "${APP_PATH}" "${STAGING_DIR}/"
ln -s /Applications "${STAGING_DIR}/Applications"

[ -f "${DMG_NAME}" ] && rm "${DMG_NAME}"

hdiutil create -volname "${APP_NAME}" \
               -srcfolder "${STAGING_DIR}" \
               -ov -format UDZO \
               "${DMG_NAME}"

rm -rf "${STAGING_DIR}"

echo "Done! ${DMG_NAME} created."
