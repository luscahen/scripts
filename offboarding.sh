

#!/bin/bash

set -e

# -------------------------
# Ask for information
# -------------------------

read -rp "Enter domain name: " DOMAIN
read -rp "Enter cPanel username: " USERNAME

DATE=$(date +%F-%H%M%S)

SITEPATH="/home/${USERNAME}/public_html"

BASE_TMP="/home/offboarding"

WORKDIR="${BASE_TMP}/${DOMAIN}-${DATE}"

ZIPNAME="${DOMAIN}-${DATE}.zip"
ZIPPATH="${BASE_TMP}/${ZIPNAME}"

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

mkdir -p "$BASE_TMP"
mkdir -p "$WORKDIR"

echo "========================================="
echo "WordPress Offboarding Started"
echo "Date: $(date)"
echo "Domain: $DOMAIN"
echo "User: $USERNAME"
echo "========================================="

# -------------------------
# Cleanup on exit/crash
# -------------------------

cleanup() {
    rm -rf "$WORKDIR"

    if [ -f "$ZIPPATH" ]; then
        rm -f "$ZIPPATH"
    fi
}

trap cleanup EXIT

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
    "wp-content/plugins/imunify-security"
    "wp-content/plugins/cleantalk-spam-protect"
    "wp-content/imunify-security"
    "wp-content/mu-plugins/superpath-mu-plugins.php"
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

zip -rq "$ZIPPATH" .

# -------------------------
# Check backup size
# -------------------------

echo "[+] Backup size:"

du -sh "$ZIPPATH"

SIZE_BYTES=$(stat -c%s "$ZIPPATH")

ONE_GB=$((1024 * 1024 * 1024))

# -------------------------
# Upload
# -------------------------

echo "[+] Uploading to Google Drive..."

if [ "$SIZE_BYTES" -ge "$ONE_GB" ]; then

    echo "[+] Large backup detected (>1GB)"
    echo "[+] Using throttled rclone settings"

    rclone copy "$ZIPPATH" Drive: \
        --progress \
        --tpslimit 1 \
        --bwlimit 3M \
        --transfers=1 \
        --checkers=1 \
        --retries 20 \
        --low-level-retries 20 \
        --retries-sleep 30s

else

    echo "[+] Using normal upload mode"

    rclone copy "$ZIPPATH" Drive: --progress

fi

# -------------------------
# Cleanup
# -------------------------

echo "[+] Cleaning up..."

rm -rf "$WORKDIR"
rm -f "$ZIPPATH"

echo
echo "[+] Offboarding completed!"
echo "[+] Uploaded:"
echo "    $ZIPNAME"

