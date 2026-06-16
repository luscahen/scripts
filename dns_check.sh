#!/usr/bin/env bash
# DNS Table Status Reporter

RED="\033[1;31m"
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
NC="\033[0m"

DOMAIN=$1
if [ -z "$DOMAIN" ]; then
  echo -e "${RED}Usage:${NC} $0 <domain>"
  exit 1
fi

# Helper for status
status_ok() { echo -e "${GREEN}[OK] Installed${NC}"; }
status_issue() { echo -e "${YELLOW}[!] Possible issue${NC}"; }
status_missing() { echo -e "${RED}[X] Missing${NC}"; }

# Helper to get TXT records
get_txt() { dig +short TXT "$1" 2>/dev/null | sed -E 's/^"//;s/"$//' ; }

# ...existing code...

# New: clean divider using a Unicode box-drawing horizontal rule
# total width = 16 (label) + 3 (" space +| + space") + 50 (value) = 69
print_divider() {
  printf '%s\n' "$(printf '%*s' 69 '' | tr ' ' '─')"
}

# --- Registrar ---
REG=$(whois "$DOMAIN" 2>/dev/null | grep -i -m1 'Registrar:' | cut -d: -f2- | xargs)
[ -z "$REG" ] && REG="[X] Not found"

# --- Nameservers (show hostnames + resolved IPs) ---
NS_LIST=$(dig +short NS "$DOMAIN" | sed 's/\.$//')
if [ -z "$NS_LIST" ]; then
  NS_OUTPUT="${CYAN}[X] Missing${NC}"
else
  NS_OUTPUT=""
  count=0
  while read -r ns; do
    # resolve A and AAAA for the nameserver
    A_IPS=$(dig +short A "$ns" | paste -sd ", " -)
    AAAA_IPS=$(dig +short AAAA "$ns" | paste -sd ", " -)

    IP_PART=""
    if [ -n "$A_IPS" ] && [ -n "$AAAA_IPS" ]; then
      IP_PART="$A_IPS, $AAAA_IPS"
    elif [ -n "$A_IPS" ]; then
      IP_PART="$A_IPS"
    elif [ -n "$AAAA_IPS" ]; then
      IP_PART="$AAAA_IPS"
    fi

    display="${CYAN}$ns${NC}"
    [ -n "$IP_PART" ] && display="$display (${IP_PART})"

    if [ $count -eq 0 ]; then
      NS_OUTPUT="$display"
    else
      NS_OUTPUT="${NS_OUTPUT}\n$(printf '%-16s' '')| $display"
    fi
    count=$((count+1))
  done <<< "$NS_LIST"
fi

# Print header
echo
print_divider
echo -e "${CYAN}DNS Status Report for: $DOMAIN${NC}"
print_divider
echo -e "Registrar       : ${CYAN}$REG${NC}"
echo -e "Nameservers     | $NS_OUTPUT"
print_divider
printf "%-16s | %-50s\n" "Record" "Value / Status"
print_divider

# --- A record ---
A_LIST=$(dig +short A "$DOMAIN" | paste -sd ", " -)
print_divider
[ -n "$A_LIST" ] && printf "%-16s | %-50s\n" "A" "$A_LIST" || printf "%-16s | %-50s\n" "A" "$(status_missing)"

# --- AAAA record ---
AAAA_LIST=$(dig +short AAAA "$DOMAIN" | paste -sd ", " -)
print_divider
[ -n "$AAAA_LIST" ] && printf "%-16s | %-50s\n" "AAAA" "$AAAA_LIST" || printf "%-16s | %-50s\n" "AAAA" "$(status_missing)"

# --- MX ---
MX_LIST=$(dig +short MX "$DOMAIN" | sort -n)
print_divider
if [ -n "$MX_LIST" ]; then
  first=true
  while read -r mx; do
    if $first; then
      printf "%-16s | %-50s\n" "MX" "$mx"
      first=false
    else
      printf "%-16s | %-50s\n" "" "$mx"
    fi
  done <<< "$MX_LIST"
else
  printf "%-16s | %-50s\n" "MX" "$(status_missing)"
fi

# --- SPF ---
print_divider
SPF_TXT=$(get_txt "$DOMAIN")
SPF=$(echo "$SPF_TXT" | grep -i 'v=spf1')
if [ -z "$SPF" ]; then
  printf "%-16s | %-50s\n" "SPF" "$(status_missing)"
else
  printf "%-16s | %-50s\n" "SPF" "$SPF"
fi

# --- DMARC ---
print_divider
DMARC=$(get_txt "_dmarc.$DOMAIN" | grep -i 'v=dmarc1')
if [ -z "$DMARC" ]; then
  printf "%-16s | %-50s\n" "DMARC" "$(status_missing)"
else
  printf "%-16s | %-50s\n" "DMARC" "$DMARC"
fi

# --- DKIM ---
print_divider
found_dkim=false
dkim_value=""
for sel in default s1 s2 google selector1 selector2 mail smtp; do
  DKIM_REC=$(get_txt "${sel}._domainkey.$DOMAIN" | grep -i 'v=DKIM1')
  if [ -n "$DKIM_REC" ]; then
    found_dkim=true
    dkim_value="$DKIM_REC"
    break
  fi
done
if [ "$found_dkim" = true ]; then
  printf "%-16s | %-50s\n" "DKIM" "$dkim_value"
else
  printf "%-16s | %-50s\n" "DKIM" "$(status_missing)"
fi

# --- SOA ---
print_divider
SOA_REC=$(dig +short SOA "$DOMAIN")
if [ -n "$SOA_REC" ]; then
  printf "%-16s | %-50s\n" "SOA" "$SOA_REC"
else
  printf "%-16s | %-50s\n" "SOA" "$(status_missing)"
fi

# --- PTR ---
print_divider
IP=$(dig +short A "$DOMAIN" | head -1)
if [ -n "$IP" ]; then
  PTR=$(dig +short -x "$IP" | paste -sd ", " -)
  [ -n "$PTR" ] && printf "%-16s | %-50s\n" "PTR" "$IP → $PTR" || printf "%-16s | %-50s\n" "PTR" "$IP → $(status_missing)"
else
  printf "%-16s | %-50s\n" "PTR" "$(status_missing)"
fi

print_divider
echo -e "${CYAN}Check complete for $DOMAIN${NC}"
echo "DNS Check: $(date '+%Y-%m-%d %H:%M:%S')"
echo
echo
# End of script