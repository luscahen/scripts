#!/bin/bash

set -e

# -------------------------
# Ask for information
# -------------------------

read -rp "Enter domain name: " DOMAIN
read -rp "Enter cPanel username: " USERNAME

DATE=$(date +%F)

SITEPATH="/home/${USERNAME}/public_html"
WORKDIR="/home/offboarding/${DOMAIN}-${DATE}"
ZIPNAME="${DOMAIN}-${DATE}.zip"

# -------------------------
# Validate path
# -------------------------

if [ ! -d "$SITEPATH" ]; then
    echo "[-] Site path not found:"
    echo "    $SITEPATH"
    exit 1
fi

# -------------------------
# Create workspace
# -------------------------

mkdir -p "$WORKDIR"

echo "[+] Copying site..."

rsync -a \
    --exclude='wp-content/cache/' \
    --exclude='*.zip' \
    --exclude='*.tar.gz' \
    "$SITEPATH/" \
    "$WORKDIR/"

# -------------------------
# Remove internal plugins
# -------------------------

echo "[+] Removing internal plugins..."

PLUGINS=(
    "wp-content/plugins/ion-wp-sso"
    "wp-content/plugins/mainwp"
    "wp-content/plugins/superpath-ion-connector"
    "wp-content/plugins/superpath-signature"
    "wp-content/plugins/footprint-wp"
    "wp-content/mu-plugins/superpath-mu-plugins"
)

for PLUGIN in "${PLUGINS[@]}"; do

    FULLPATH="$WORKDIR/$PLUGIN"

    if [ -e "$FULLPATH" ]; then
        echo "    Removing: $PLUGIN"
        rm -rf "$FULLPATH"
    else
        echo "    Not found: $PLUGIN"
    fi

done

# -------------------------
# Export database
# -------------------------

echo "[+] Exporting database..."

wp db export "$WORKDIR/database.sql" \
    --path="$SITEPATH" \
    --allow-root

# -------------------------
# Create ZIP
# -------------------------

echo "[+] Creating ZIP..."

cd "$WORKDIR"

zip -rq "/home/offboarding/$ZIPNAME" .

# -------------------------
# Upload
# -------------------------

echo "[+] Uploading to Google Drive..."

rclone copy "/home/offboarding/$ZIPNAME" Drive: --progress

# -------------------------
# Cleanup
# -------------------------

echo "[+] Cleaning up..."

rm -rf "$WORKDIR"
rm -f "/home/offboarding/$ZIPNAME"

echo
echo "[+] Offboarding completed!"
echo "[+] Uploaded:"
echo "    $ZIPNAME"
