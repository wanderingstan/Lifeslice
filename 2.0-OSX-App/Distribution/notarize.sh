#!/bin/bash
#
# Build, sign, notarize and staple LifeSlice, then emit a Sparkle 2 appcast.
#
# Replaces the hand-rolled appcast in lifeslice_package.command. Gatekeeper has
# refused un-notarized apps since Catalina, so shipping the old way now produces
# a download nobody can open.
#
# One-time setup, both of which store secrets and so are left to you:
#
#   1. Notarization credentials. Make an app-specific password at
#      https://appleid.apple.com, then:
#
#        xcrun notarytool store-credentials lifeslice-notary \
#          --apple-id <your-apple-id> --team-id PNPVJ6J7X2
#
#   2. Sparkle EdDSA signing keys, whose private half lives in your keychain:
#
#        ./sparkle-tools/generate_keys
#
#      Put the public key it prints into SUPublicEDKey in LifeSlice-Info.plist.
#
set -euo pipefail

cd "$(dirname "$0")"

KEYCHAIN_PROFILE="${KEYCHAIN_PROFILE:-lifeslice-notary}"
TEAM_ID="${TEAM_ID:-PNPVJ6J7X2}"
PRODUCT_NAME="LifeSlice"
PROJECT="../LifeSlice.xcodeproj"
INFO_PLIST="../LifeSlice-Info.plist"
BUILD_DIR="$(pwd)/build"
RELEASE_DIR="$(pwd)/releases"

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFO_PLIST")
SHORT_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$INFO_PLIST")

echo "==> Building ${PRODUCT_NAME} ${SHORT_VERSION} (${VERSION})"

# Refuse to ship with the placeholder key still in place: Sparkle would hand
# users an update it cannot verify.
PUBLIC_KEY=$(/usr/libexec/PlistBuddy -c "Print :SUPublicEDKey" "$INFO_PLIST" 2>/dev/null || echo "")
if [[ "$PUBLIC_KEY" == "REPLACE_WITH_EDDSA_PUBLIC_KEY" || -z "$PUBLIC_KEY" ]]; then
    echo "ERROR: SUPublicEDKey is not set. Run ./sparkle-tools/generate_keys and" >&2
    echo "       put the public key in ${INFO_PLIST}." >&2
    exit 1
fi

rm -rf "$BUILD_DIR"
mkdir -p "$RELEASE_DIR"

# archive, rather than build, so both architectures are produced
echo "==> Archiving"
xcodebuild -project "$PROJECT" \
    -scheme "$PRODUCT_NAME" \
    -configuration Release \
    -archivePath "$BUILD_DIR/${PRODUCT_NAME}.xcarchive" \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY="Developer ID Application" \
    archive

APP=$(find "$BUILD_DIR/${PRODUCT_NAME}.xcarchive/Products" -name "${PRODUCT_NAME}.app" -maxdepth 4 | head -1)
[[ -n "$APP" ]] || { echo "ERROR: no .app in archive" >&2; exit 1; }

echo "==> Built: $(lipo -info "$APP/Contents/MacOS/${PRODUCT_NAME}" | sed 's/.*: //')"
codesign --verify --strict --verbose=1 "$APP"

# notarytool takes a zip, and ditto is the only archiver that preserves the
# bundle's symlinks and extended attributes intact
ZIP="$RELEASE_DIR/${PRODUCT_NAME}_${VERSION}.zip"
rm -f "$ZIP"
echo "==> Zipping for submission"
ditto -c -k --keepParent "$APP" "$ZIP"

echo "==> Submitting to Apple (this usually takes a few minutes)"
xcrun notarytool submit "$ZIP" \
    --keychain-profile "$KEYCHAIN_PROFILE" \
    --wait

# Stapling attaches the ticket to the bundle so Gatekeeper clears it even when
# the user is offline. It has to happen on the .app, then be re-zipped.
echo "==> Stapling"
xcrun stapler staple "$APP"
xcrun stapler validate "$APP"

rm -f "$ZIP"
ditto -c -k --keepParent "$APP" "$ZIP"

echo "==> Verifying as Gatekeeper sees it"
spctl --assess --type execute --verbose=2 "$APP"

cp -R "$APP" "$RELEASE_DIR/" 2>/dev/null || true

echo "==> Generating Sparkle appcast"
./sparkle-tools/generate_appcast "$RELEASE_DIR"

echo
echo "Done. Notarized and stapled:"
echo "  $ZIP"
echo "  $RELEASE_DIR/appcast.xml"
echo
echo "Upload both to the host serving SUFeedURL."
