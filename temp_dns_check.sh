#!/bin/sh

# Usage: ./check_dns.sh domains.txt

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    exit 1
fi

while IFS= read -r domain; do
    # Skip empty lines
    [ -z "$domain" ] && continue

    echo "==============================="
    echo "Domain: $domain"

    # A record
    echo -n "A Record: "
    a_record=$(dig +short A "$domain")
    if [ -z "$a_record" ]; then
        echo "NO A RECORD"
    else
        echo "$a_record"
    fi

#    # MX record
#    echo -n "MX Record: "
#    mx_record=$(dig +short MX "$domain")
#    if [ -z "$mx_record" ]; then
#        echo "NO MX RECORD"
#    else
#        echo "$mx_record"
#    fi

    # SPF record
    echo -n "SPF Record: "
    spf_record=$(dig +short TXT "$domain" | grep -i "v=spf1")
    if [ -z "$spf_record" ]; then
        echo "NO SPF RECORD"
    else
        echo "$spf_record"
    fi

    echo ""
done < "$FILE"
