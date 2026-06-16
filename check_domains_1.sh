#!/bin/bash

# -----------------------------
# Parallel arrays for IP ↔ hostname
# -----------------------------
TARGET_IPS=(
   "72.52.188.178"
   "67.227.170.196"
   "209.59.137.200"
   "172.98.64.218"
   "172.208.67.119"
   "172.210.17.123"
   "40.124.186.9"
   "20.169.109.92"
   "40.124.185.54"
   "4.150.189.46"
   "20.3.147.243"
   "172.206.13.127"
   "20.121.45.48"
   "52.180.156.195"
   "20.65.225.182"
   "209.59.137.156"
   "67.227.171.62"
   "67.227.170.36"
   "67.227.171.112"
   "67.227.170.134"   
)
TARGET_NAMES=(
   "c1.highlevelmarketing.net"
   "c2.highlevelmarketing.net"
   "corp.highlevelmarketing.net"
   "cloud1.highlevelmarketing.net"
   "wpa01.highlevelmarketing.net"
   "wpa02.highlevelmarketing.net"
   "wpa03.highlevelmarketing.net"
   "wpa04.highlevelmarketing.net"
   "wpa05.highlevelmarketing.net"
   "wpa06.highlevelmarketing.net"
   "wpa07.highlevelmarketing.net"
   "ca01.highlevelmarketing.net"
   "ca02.highlevelmarketing.net"
   "ca03.highlevelmarketing.net"
   "ca04.highlevelmarketing.net"
   "wp9.highlevelmarketing.net"
   "wp10.highlevelmarketing.net"
   "wp11.highlevelmarketing.net"
   "wp12.highlevelmarketing.net"
   "wp13.highlevelmarketing.net"
)

# -----------------------------
# Domains to Check
# -----------------------------
DOMAINS=(

aircomfortne.com
americancoolingservice.com
ardmorecpa.com
ardmorefamilyymca.org
ardmoremainstreet.com
ardmorevillage.com
badonbugs.com
boblarsonplumbing.com
bradywelding.com
bridgecommunications.biz
bustthecuffs.com
cardinalplumbingva.com
citiesinschoolsardmore.org
citizensbt.com
cmcserviceexperts.com
crandallheatingandair.com
daffanmechanical.com
dfm-associates.com
dillonenv.com
diverseconstructionok.com
diversedumpsterrental.com
drmariestarling.com
eckelectric.com
elitepools.com
elliottrentalandequipment.com
environmentalimpact.us
freefloplumbing.com
freshinepros.com
frymire.com
glowmedicaltulsa.com
Halpaschombe
hardymurphycoliseum.com
helphascome.com
indiantaxcredit.com
infinityplumbingservices.com
jblantonplumbing.com
Johnson Heating, Cooling, Plumbing
jolliffcoffee.com
katy-plumber.com
lawworcester.com
mcgill-lawoffices.com
mkhelectronics.com
mkhservicedesk.com
moreboom.com
naturemedsok.com
ndsdigital.com
notanku.com
oppincok.org
pantherhvac.com
pestcontrol-now.com
rcdpetresort.com
reliabilityhome.com
reliableheatandair.com
ricketsfennell.com
rootersharkplumbing.com
serviceplumbingcoinc.com
shannaandco.com
smithcarney.com
soas.net
strittmatters.com
successtracknetwork.com
svcninja.com
technicalartscenter.com
teslaelectriccolorado.com
thctexoma.com
TTT Home Services
underwoodplumbingandseptic.com
uwsco.org
woodfloordallas.com
yourairco.com

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
