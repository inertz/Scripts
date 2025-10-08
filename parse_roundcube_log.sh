#!/bin/bash
# Script to parse Roundcube webmail access logs
# Extracts: IP | Email | Date/Time | Success/Fail

# Usage: ./parse_roundcube_log.sh /path/to/access_log

LOGFILE="$1"
OUTPUT="roundcube_parsed.txt"

if [[ -z "$LOGFILE" ]]; then
    echo "Usage: $0 /path/to/access_log"
    exit 1
fi

if [[ ! -f "$LOGFILE" ]]; then
    echo "Error: Log file not found: $LOGFILE"
    exit 1
fi

# Clear output before writing
> "$OUTPUT"

echo "Processing $LOGFILE ..."
echo "IP | Email | DateTime | Status" >> "$OUTPUT"
echo "---------------------------------------------" >> "$OUTPUT"

awk '
{
    ip=$1;
    email="-";
    datetime="-";
    status="-";

    # Extract email (after proxy or dash)
    if ($2 == "proxy" || $2 == "-") {
        email_field = $3;
        gsub("%40", "@", email_field);
        email = email_field;
    }

    # Extract datetime in [brackets]
    match($0, /\[([0-9\/: -]+)\]/, dt);
    if (dt[1] != "") datetime = dt[1];

    # Get HTTP status code
    match($0, /" [0-9]+ /);
    if (RSTART) {
        code = substr($0, RSTART+2, RLENGTH-3);
        if (code == 200)
            status="Success";
        else
            status="Fail";
    }

    printf("%s | %s | %s | %s\n", ip, email, datetime, status);
}' "$LOGFILE" >> "$OUTPUT"

echo "Done! Output saved to $OUTPUT"
