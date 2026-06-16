#!/bin/bash

INPUT="domains.txt"
OUTPUT="domain-report.txt"

echo "Domain check report - $(date)" > "$OUTPUT"
echo "----------------------------------" >> "$OUTPUT"

while IFS= read -r domain; do
  [[ -z "$domain" ]] && continue

  echo "Checking: $domain"

  # Get IP
  ip=$(dig +short A "$domain" | head -n1)
  [[ -z "$ip" ]] && ip="No IP found"

  # Get Nameservers
  ns=$(dig +short NS "$domain")
  [[ -z "$ns" ]] && ns="No NS found"

  # Get Registrar
  registrar=$(whois "$domain" 2>/dev/null | grep -i "Registrar:" | head -n1 | sed 's/Registrar://I' | xargs)
  [[ -z "$registrar" ]] && registrar="No registrar found"

  {
    echo "Domain: $domain"
    echo "IP: $ip"
    echo "Nameservers:"
    echo "$ns"
    echo "Registrar: $registrar"
    echo "----------------------------------"
  } >> "$OUTPUT"

done < "$INPUT"

echo "Done. Report saved in $OUTPUT"
