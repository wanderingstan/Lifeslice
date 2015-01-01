#!/bin/sh

# TODO: New sparkle requires that we just zip the app, and nothing more.

# Command to take signed app, put it in a zip, create Sparkle appcast XML, and (optionally) upload to server

# Load FTP details
source distribution_setup_no_commit.sh

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" ../LifeSlice-Info.plist)
SHORT_VERSION_STRING=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" ../LifeSlice-Info.plist)

PRODUCT_NAME="LifeSlice" 
APPCAST_FILENAME="lifeslice_appcast.xml"

DOWNLOAD_BASE_URL="http://www.wanderingstan.com/apps/lifeslice"
RELEASENOTES_URL="http://www.wanderingstan.com/apps/lifeslice/$VERSION.html"
NOTES_FILENAME="${VERSION}.html"

# --------------------------------------------------------------------


echo "Creating Sparkle Update for: ${PRODUCT_NAME} Version ${SHORT_VERSION_STRING} ($VERSION)"


# Create the DMG (for first download)
DMG_FILENAME="${PRODUCT_NAME}.dmg"
rm "${DMG_FILENAME}"
echo "Creating DMG file: ${DMG_FILENAME}"
hdiutil create "${DMG_FILENAME}" -srcfolder ./LifeSlice/ -ov

# Create the ZIP
ZIP_FILENAME="${PRODUCT_NAME}_${VERSION}.zip"
echo "Creating ZIP file: ${ZIP_FILENAME}"
ditto -ck --rsrc --sequesterRsrc "./${PRODUCT_NAME}/${PRODUCT_NAME}.app" "${ZIP_FILENAME}"

DISTRIBUTION_FILENAME="${DMG_FILENAME}"

DOWNLOAD_URL="$DOWNLOAD_BASE_URL/$DISTRIBUTION_FILENAME"
echo "Download URL: ${DOWNLOAD_URL}"
echo "Release Notes URL: ${RELEASENOTES_URL}"

SIZE=$(stat -f %z "$DISTRIBUTION_FILENAME")
PUBDATE=$(LC_TIME=en_US date +"%a, %d %b %G %T %z")
 
cat > update_$VERSION.xml <<EOF
        <item>
            <title>${PRODUCT_NAME} Version ${SHORT_VERSION_STRING} ($VERSION)</title>
            <sparkle:releaseNotesLink>$RELEASENOTES_URL</sparkle:releaseNotesLink>
            <pubDate>$PUBDATE</pubDate>
            <enclosure
                url="$DOWNLOAD_URL"
                sparkle:version="$VERSION"
                sparkle:shortVersionString="${SHORT_VERSION_STRING}"
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

# Create release notes stub
cat > "${NOTES_FILENAME}" <<EOF
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>LifeSlice Update</title>
</head>
<body>

<ul>
<li></li>
<li></li>
<li></li>
<li></li>
</ul>

</body>
</html>
EOF
echo "Created notes html file: ${ZIP_FILENAME}"


# Upload and update XML
echo
echo
echo
read -p "Upload appcast to server ${FTP_HOST}? (y/n)" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    ftp -n $FTP_HOST <<END_SCRIPT
    quote USER $FTP_USER
    quote PASS $FTP_PASSWORD
    put $DISTRIBUTION_FILENAME
    put $DMG_FILENAME
    put $APPCAST_FILENAME
    quit
END_SCRIPT
    exit 0

fi