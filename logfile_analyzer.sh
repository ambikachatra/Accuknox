#!/bin/bash


# Check if a log file was provided as an argument.
if [ -z "$1" ]; then
    echo "ERROR: No log file specified."
    echo "Usage: $0 /home/ambikac/Desktop/PS2"
    exit 1
fi

LOG_FILE="$1"

# Check if the specified log file exists and is readable.
if [ ! -f "$LOG_FILE" ]; then
    echo "ERROR: Log file not found at '$LOG_FILE'"
    exit 1
fi

# --- ANALYSIS ---

echo "============================================="
echo " Web Server Log Analysis Report for: $LOG_FILE"
echo " Report generated on: $(date)"
echo "============================================="
echo ""


# 1. Calculate Total Number of Requests (total lines in the log).
TOTAL_REQUESTS=$(wc -l < "$LOG_FILE")
echo "Total Requests: $TOTAL_REQUESTS"
echo "---------------------------------------------"


# 2. Count the number of 404 Not Found errors.

FOUR_OH_FOUR_ERRORS=$(grep '" 404 ' "$LOG_FILE" | wc -l)
echo "Number of 404 Errors: $FOUR_OH_FOUR_ERRORS"
echo "---------------------------------------------"


# 3. List the 10 most requested pages.
echo "Top 10 Most Requested Pages:"
awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -n 10 | awk '{print "  " $1 " requests - " $2}'
echo "---------------------------------------------"


# 4. List the 10 IP addresses with the most requests.
echo "Top 10 IP Addresses by Request Count:"
# awk '{print $1}' -> Extracts the 1st column (the IP address).
# The rest of the pipeline is the same logic as for requested pages.
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -n 10 | awk '{print "  " $1 " requests - " $2}'
echo "---------------------------------------------"

echo "Analysis complete."
