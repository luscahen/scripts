#!/bin/bash

DOMAIN="$1"

if [[ -z "$DOMAIN" ]]; then
    echo "Usage: $0 example.com"
    exit 1
fi

echo "🔍 Enumerating + Resolving + ASN Lookup for: $DOMAIN"
echo

command -v subfinder >/dev/null 2>&1 || { echo "❌ subfinder not found"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "❌ jq not found"; exit 1; }

subfinder -silent -d "$DOMAIN" | while read sub; do
    # Get all IP addresses (one per line)
    ips=$(host "$sub" 2>/dev/null | grep "has address" | awk '{print $4}')

    if [[ -n "$ips" ]]; then
        # Join multiple IPs into one line (space-separated)
        ips_one_line=$(echo "$ips" | tr '\n' ' ' | sed 's/ $//')

        # Get ASN based on the first IP
        first_ip=$(echo "$ips" | head -n 1)
        asn=$(curl -s "https://ipinfo.io/$first_ip/json" | jq -r '.org // "Unknown"')

        echo "$sub - $ips_one_line - $asn"
    else
        :
        # Uncomment below if you WANT to display NO DNS entries:
        # echo "$sub - NO DNS"
    fi
done