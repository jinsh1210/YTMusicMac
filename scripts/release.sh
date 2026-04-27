#!/bin/bash

# YTMusicMac Release Script
# Automates: [xcodegen] -> xcodebuild -> hdiutil (.dmg) -> git tag -> gh release upload

set -e

cd "$(dirname "$0")/.."

APP_NAME="YTMusicMac"
SCHEME="YTMusicMac"
CONFIGURATION="Release"
BUILD_DIR="build"
APP_PATH="${BUILD_DIR}/Build/Products/${CONFIGURATION}/${APP_NAME}.app"
DMG_NAME="${APP_NAME}.dmg"
STAGING_DIR="/tmp/${APP_NAME}-dmg-staging"

VERSION=$(grep 'MARKETING_VERSION:' project.yml | awk '{print $2}')
TAG="v${VERSION}"

# Step 1: XcodeGen
if command -v xcodegen &> /dev/null; then
    echo "Step 1: Generating project with XcodeGen..."
    xcodegen generate
else
    echo "Step 1: XcodeGen not installed — using existing project file."
fi

# Step 2: Build
echo "Step 2: Building ${VERSION}..."
xcodebuild -project "${APP_NAME}.xcodeproj" \
           -scheme "${SCHEME}" \
           -configuration "${CONFIGURATION}" \
           -derivedDataPath "${BUILD_DIR}" \
           clean build | grep -E "^(Build|error:|warning:|\\*\\*)" || true

if [ ! -d "${APP_PATH}" ]; then
    echo "Error: Build failed — ${APP_PATH} not found."
    exit 1
fi

# Step 3: DMG 생성
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

echo "DMG created: ${DMG_NAME}"

# Step 4: Git tag
echo "Step 4: Tagging ${TAG}..."
if git rev-parse "${TAG}" >/dev/null 2>&1; then
    echo "Tag ${TAG} already exists — skipping tag creation."
else
    git tag "${TAG}"
    git push origin "${TAG}"
    echo "Pushed tag ${TAG}."
fi

# Step 5: GitHub Release 업로드
echo "Step 5: Uploading to GitHub Release..."
if ! command -v gh &> /dev/null; then
    echo "Error: gh CLI not installed. Run: brew install gh"
    exit 1
fi

if gh release view "${TAG}" >/dev/null 2>&1; then
    echo "Release ${TAG} already exists — uploading DMG..."
    gh release upload "${TAG}" "${DMG_NAME}" --clobber
else
    gh release create "${TAG}" "${DMG_NAME}" \
        --title "${TAG}" \
        --notes "Release ${TAG}"
fi

echo "Done! ${TAG} released."
