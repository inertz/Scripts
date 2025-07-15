#!/bin/bash

# Set temperature threshold
THRESHOLD=60

# Get the current CPU temperature (modify grep pattern if needed)
TEMP=$(sensors | grep -m 1 'Package id 0:' | awk '{print $4}' | tr -d '+°C')

# Check if temperature was read successfully
if [ -z "$TEMP" ]; then
    echo "Could not read CPU temperature."
    exit 1
fi

# Convert to integer
TEMP_INT=${TEMP%.*}

# Compare with threshold
if [ "$TEMP_INT" -ge "$THRESHOLD" ]; then
    SUBJECT="CPU Temperature Alert: ${TEMP}°C"
    BODY="Warning: CPU temperature has reached ${TEMP}°C on $(hostname) at $(date)."
    echo "$BODY" | mail -s "$SUBJECT" support@domain.com
    echo "Alert sent to support@domain.com"
fi
