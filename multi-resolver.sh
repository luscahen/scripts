#!/bin/bash
# Usage: ./check-dns.sh domain.com
# Example: ./check-dns.sh commercial.schonsheck.com

DOMAIN="$1"
TARGET_IP="20.3.147.243"   # <-- change if you need to monitor another target IP
DNS_SERVERS=("1.1.1.1" "8.8.8.8" "8.8.4.4" "9.9.9.9" "208.67.222.222" "4.2.2.2" "76.76.2.0" "94.140.14.14")
INTERVAL=300  # seconds (5 minutes)
LOG_FILE="./dns-propagation-$DOMAIN.log"

if [ -z "$DOMAIN" ]; then
  echo "❌ Usage: $0 <domain>"
  exit 1
fi

echo "🌎 Monitoring DNS propagation for $DOMAIN → $TARGET_IP"
echo "Resolvers: ${DNS_SERVERS[*]}"
echo "Checking every $((INTERVAL/60)) minutes..."
echo "Logs: $LOG_FILE"
echo "---------------------------------------------" | tee -a "$LOG_FILE"

while true; do
  echo
  echo "🔍 Checking at $(date)..." | tee -a "$LOG_FILE"
  all_ok=true

  for dns in "${DNS_SERVERS[@]}"; do
    ip=$(dig +short "$DOMAIN" @"$dns" | tail -n1)
    if [ "$ip" = "$TARGET_IP" ]; then
      echo "✅ $dns → $ip" | tee -a "$LOG_FILE"
    else
      echo "❌ $dns → $ip" | tee -a "$LOG_FILE"
      all_ok=false
    fi
  done

  if [ "$all_ok" = true ]; then
    echo " All resolvers now point to $TARGET_IP!" | tee -a "$LOG_FILE"
    #say "DNS propagation complete for $DOMAIN" 2>/dev/null || true
    break
  else
    echo " Some resolvers still old. Rechecking in $((INTERVAL/60)) min..." | tee -a "$LOG_FILE"
    sleep "$INTERVAL"
  fi
done

