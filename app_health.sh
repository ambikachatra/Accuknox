#!/bin/bash
# Check if a URL was provided as an argument.
if [ -z "$1" ]; then
    echo "ERROR: No URL specified."
    echo "Usage: $0 <URL_to_check>"
    exit 1
fi
URL_TO_CHECK="$1"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

echo "[$TIMESTAMP] Checking status of: $URL_TO_CHECK"

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL_TO_CHECK")

if [ "$HTTP_STATUS" -eq 000 ]; then
    echo "[$TIMESTAMP] STATUS: DOWN - Could not connect to the server."
    exit 1
fi

if [ "$HTTP_STATUS" -ge 200 ] && [ "$HTTP_STATUS" -lt 400 ]; then
    echo "[$TIMESTAMP] STATUS: UP - Received status code $HTTP_STATUS."
    exit 0
else
    echo "[$TIMESTAMP] STATUS: DOWN - Received status code $HTTP_STATUS."
    exit 1
fi
