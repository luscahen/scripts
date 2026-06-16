#!/bin/bash

# -----------------------------
# Parallel arrays for IP ↔ hostname
# -----------------------------
TARGET_IPS=(
#  "172.98.64.218"
  "20.121.45.48"
  "52.180.156.195"
  "20.65.225.182"
)

TARGET_NAMES=(
#  "cloud1.highlevelmarketing.net"
  "ca02.highlevelmarketing.net"
  "ca03.highlevelmarketing.net"
  "ca04.highlevelmarketing.net"
)

# -----------------------------
# Domains to Check
# -----------------------------
DOMAINS=(
amcenvironmental.org
andyelder.net
atlascarpetclean.com
automotivecolorsupply.com
cakecrumbsonline.com
cgeelectricalservices.com
christyhardware.com
epswash.com
flordrisupply.com
garciaslandscapingco.com
go.seghi.net
haweselectric.com
industrialresin.com
lawsonandlawsonplc.com
m-rmechanical.com
mcdmd.com
michiganphysicianssociety.com
occupancysolutions.com
performanceengineering.com
postconstructionllc.com
premierfootandanklemi.com
pureductsmi.com
sparkle-dental.com
ssbroadband.com
storage-one.ca
treeincllc.com
triplejlawnandlandscape.com
)

# -----------------------------
# Terminal Colors
# -----------------------------
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# -----------------------------
# Functions
# -----------------------------
is_ip() {
  echo "$1" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
}

# Returns 0 if IP is in list, and sets `MATCHED_NAME` variable
ip_matches_target() {
  MATCHED_NAME=""
  local ip="$1"
  local i=0
  while [ $i -lt ${#TARGET_IPS[@]} ]; do
    if [ "$ip" = "${TARGET_IPS[$i]}" ]; then
      MATCHED_NAME="${TARGET_NAMES[$i]}"
      return 0
    fi
    i=$((i + 1))
  done
  return 1
}

# -----------------------------
# Execution
# -----------------------------
echo "🔍 Checking ${#DOMAINS[@]} domains..."
echo "🎯 Matching against:"
i=0
while [ $i -lt ${#TARGET_IPS[@]} ]; do
  echo "   • ${TARGET_IPS[$i]} → ${TARGET_NAMES[$i]}"
  i=$((i + 1))
done
echo "-----------------------------------------"

for domain in "${DOMAINS[@]}"; do
  domain=$(echo "$domain" | xargs)
  [ -z "$domain" ] && continue

  raw_dig_output=$(dig +short "$domain" | head -n 1)
  ip_address=""
  cname_note=""

  if is_ip "$raw_dig_output"; then
    ip_address="$raw_dig_output"
  else
    cleaned_cname=$(echo "$raw_dig_output" | sed 's/\.$//')
    if [ -n "$cleaned_cname" ]; then
      second_dig_output=$(dig +short "$cleaned_cname" | head -n 1)
      if is_ip "$second_dig_output"; then
        ip_address="$second_dig_output"
        cname_note=" (via CNAME → $cleaned_cname)"
      fi
    fi
  fi

  if [ -z "$ip_address" ]; then
    echo -e "$domain: ${RED}No A record found${NC} (or unresolved CNAME)"
  elif ip_matches_target "$ip_address"; then
    echo -e "$domain: ${GREEN}$ip_address${NC} → $MATCHED_NAME$cname_note"
  else
    echo -e "$domain: ${RED}$ip_address${NC} (non-matching IP)$cname_note"
  fi
done

echo "-----------------------------------------"
echo "✅ Done."
