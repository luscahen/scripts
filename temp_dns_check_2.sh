#!/bin/sh

# Usage: ./spf_with_domain.sh domains.txt

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE" >&2
    exit 1
fi

while IFS= read -r domain; do
    [ -z "$domain" ] && continue

    spf=$(dig +short TXT "$domain" | grep -i 'v=spf1')

    if [ -z "$spf" ]; then
        echo "$domain: NO SPF"
    else
        echo "$domain: $spf"
    fi
done < "$FILE"
