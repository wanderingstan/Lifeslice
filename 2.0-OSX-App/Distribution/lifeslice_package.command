#!/bin/sh

# Command to take signed app, put it in a DMG, create Sparkle appcast XML, and (optionally) upload to server

# Load FTP details
source distribution_setup_no_commit.sh

PRODUCT_NAME="LifeSlice" 
APPCAST_FILENAME="lifeslice_appcast.xml"
DOWNLOAD_BASE_URL="http://www.wanderingstan.com/apps/lifeslice"
RELEASENOTES_URL="http://www.wanderingstan.com/apps/lifeslice/$VERSION.html"

# --------------------------------------------------------------------

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" ../LifeSlice-Info.plist)
SHORT_VERSION_STRING=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" ../LifeSlice-Info.plist)

echo "Creating Sparkle Update for: ${PRODUCT_NAME} Version $VERSION"

DMG_FILENAME="${PRODUCT_NAME}.dmg"
ZIP_FILENAME="${PRODUCT_NAME}_${VERSION}.zip"

# Create the DMG
rm "${DMG_FILENAME}"
echo "Creating DMG file: ${DMG_FILENAME}"
hdiutil create "${DMG_FILENAME}" -srcfolder ./LifeSlice/ -ov

# Create the ZIP
echo "Creating ZIP file: ${ZIP_FILENAME}"
ditto -ck --rsrc --sequesterRsrc "${DMG_FILENAME}" "${ZIP_FILENAME}"

DOWNLOAD_URL="$DOWNLOAD_BASE_URL/$ZIP_FILENAME"
echo "Download URL: ${DOWNLOAD_URL}"
 
SIZE=$(stat -f %z "$ZIP_FILENAME")
PUBDATE=$(LC_TIME=en_US date +"%a, %d %b %G %T %z")
 
cat > update_$VERSION.xml <<EOF
        <item>
            <title>${PRODUCT_NAME} Version ${SHORT_VERSION_STRING} ($VERSION)</title>
            <sparkle:releaseNotesLink>$RELEASENOTES_URL</sparkle:releaseNotesLink>
            <pubDate>$PUBDATE</pubDate>
            <enclosure
                url="$DOWNLOAD_URL"
                sparkle:version="$VERSION"
                type="application/octet-stream"
                length="$SIZE"
            />
        </item>

EOF

# re-create our master XML 
rm "$APPCAST_FILENAME"

cat > "${APPCAST_FILENAME}" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"  xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>

        <title>${PRODUCT_NAME} Changelog</title>
        <link>${DOWNLOAD_BASE_URL}${APPCAST_FILENAME}</link>
        <description>Most recent changes with links to updates.</description>
        <language>en</language>

EOF

# add all of our updates to XML
cat update*.xml >> "${APPCAST_FILENAME}"

cat >> "${APPCAST_FILENAME}" <<EOF 
    </channel>
</rss>
EOF


# Upload and update XML

read -p "Upload appcast to server ${FTP_HOST}? (y/n)" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    ftp -n $FTP_HOST <<END_SCRIPT
    quote USER $FTP_USER
    quote PASS $FTP_PASSWORD
    put $DMG_FILENAME
    put $ZIP_FILENAME
    put $APPCAST_FILENAME
    quit
END_SCRIPT
    exit 0

fi