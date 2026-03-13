#!/bin/bash

#################################
# SCRIPT INFO
#################################

SCRIPT_NAME="Daily Server Health Check"
SCRIPT_VERSION="1.2.3"
SCRIPT_UPDATE="Repair SMART Reporting Bug"
UPDATE_URL="https://reporting.inertz.org/scripts/daily-report.sh"
TMP_SCRIPT="/tmp/daily-report.sh"
LOG_FILE="/var/log/daily-report-update.log"

#################################
# SELF UPDATE CHECK
#################################

echo "Checking script version..."

wget -q -O "$TMP_SCRIPT" "$UPDATE_URL"

if [ -s "$TMP_SCRIPT" ]; then

REMOTE_VERSION=$(grep SCRIPT_VERSION "$TMP_SCRIPT" | head -1 | cut -d'"' -f2)

if [ -z "$REMOTE_VERSION" ]; then

    echo "Unable to detect remote version. Skipping update."

elif [ "$REMOTE_VERSION" != "$SCRIPT_VERSION" ]; then

    echo "New version detected: $REMOTE_VERSION"
    echo "Updating script..."

    cp "$TMP_SCRIPT" "$0"
    chmod +x "$0"

    echo "$(date) Updated script from $SCRIPT_VERSION to $REMOTE_VERSION" >> "$LOG_FILE"

    echo "Script updated. New version will run on next execution."
    exit 0

else

    echo "Script already latest version ($SCRIPT_VERSION)"

fi

rm -f "$TMP_SCRIPT"

else

echo "Unable to download update. Using local version."

fi

echo ""

#################################
# REPORT HEADER
#################################

echo "================================="
echo "$SCRIPT_NAME"
echo "Version    : $SCRIPT_VERSION"
echo "Update log : $SCRIPT_UPDATE"
echo "Hostname   : $(hostname)"
echo "Date       : $(date)"
echo "================================="
echo ""

#################################
# MYSQL BACKUP CHECK
#################################

echo "---- MySQL Backup Latest ----"

BACKUP_DIR="/backup/mysqlbackup"

if [ -d "$BACKUP_DIR" ]; then
    latest_backup=$(ls -t $BACKUP_DIR 2>/dev/null | head -n1)

    if [ ! -z "$latest_backup" ]; then
        echo "Latest Backup File : $latest_backup"
        stat $BACKUP_DIR/$latest_backup
        echo "STATUS : OK"
    else
        echo "STATUS : WARNING - No backup file found"
    fi
else
    echo "STATUS : WARNING - Backup directory not found"
fi

echo ""



#################################
# SMART DISK CHECK
#################################

echo "---- Disk Health (SMART) ----"

for disk in $(lsblk -d -n -o NAME | grep -Ev "loop|ram")
do

DEVICE="/dev/$disk"

result=$(/usr/sbin/smartctl -H "$DEVICE" 2>/dev/null | grep -i "result")

if echo "$result" | grep -qi "PASSED"; then
echo "$DEVICE : OK"
else
echo "$DEVICE : ISSUE"
fi

done

echo ""

#################################
# SOFTWARE RAID CHECK
#################################

echo "---- RAID Status (Software RAID) ----"

if [ -f /proc/mdstat ]; then
    cat /proc/mdstat

    if cat /proc/mdstat | grep -q "\[UU\]"; then
        echo "STATUS : OK"
    else
        echo "STATUS : WARNING - RAID may be degraded"
    fi
else
    echo "No software RAID detected"
fi

echo ""

#################################
# HARDWARE RAID CHECK
#################################

echo "---- RAID Status (Hardware RAID Check) ----"

if command -v megacli >/dev/null 2>&1; then
    megacli -LDInfo -Lall -aALL
elif command -v storcli >/dev/null 2>&1; then
    storcli /c0/vall show
elif command -v arcconf >/dev/null 2>&1; then
    arcconf getconfig 1
else
    echo "No hardware RAID tool detected"
fi

echo ""

#################################
# DISK SPACE CHECK
#################################

echo "---- Disk Space ----"

df -hP | awk 'NR>1 {print $5 " " $6}' | while read output
do

usage=$(echo $output | awk '{print $1}' | sed 's/%//')
partition=$(echo $output | awk '{print $2}')

if [ "$usage" -ge 90 ]; then
echo "ISSUE : Disk usage on $partition is ${usage}%"
else
echo "OK : Disk usage on $partition is ${usage}%"
fi

done

echo ""



#################################
# REPORT END
#################################

echo "================================="
echo "Report completed"
echo "================================="
