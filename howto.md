# Daily Server Health Check Script

A lightweight **Linux server monitoring script** designed for automated daily health checks.  
The script can run manually or via **cron job**, generate a server status report, and optionally send the result via email.

It also includes a **self-update mechanism** so all servers can automatically update to the latest script version from a central source.

---

# Features

- Self-updating script using `SCRIPT_VERSION`
- Disk usage monitoring (**alerts if ≥ 90%**)
- SMART disk health check (SATA / SSD / NVMe)
- Software RAID status check (`/proc/mdstat`)
- MySQL backup detection
- Clean report output suitable for email or audit
- Update logging for version changes

---

# Requirements

The following utilities must exist on the server:

- `bash`
- `wget`
- `smartctl` (smartmontools)
- `lsblk`
- `mail` or `mailx` (for email reports)

## Install SMART tools

### CentOS / AlmaLinux / RHEL

```bash
yum install smartmontools -y

### Debian / Ubuntu

```bash
apt install smartmontools -y
Installation
1. Download the Script

Example location:

/backup/daily-report.sh
2. Make it Executable
chmod +x /backup/daily-report.sh
3. Test Manually
/backup/daily-report.sh
Cron Job Setup

To run the script daily and email the report:

0 9 * * * /backup/daily-report.sh | mail -s "Daily Shared Server Report $(hostname)" alert@iwhost.com

This will:

Check script version

Update the script if a new version exists

Run the server health report

Send the report via email

Self Update Mechanism

The script supports automatic updates from a central server.

Example variables inside the script:

SCRIPT_VERSION="1.0"
UPDATE_URL="https://monitor.example.com/scripts/daily-report.sh"
Update Process

Script downloads the remote version

Compares SCRIPT_VERSION

If the version is different:

Script updates itself

Logs the update

New version runs on the next execution

Example Output
=================================
Daily Server Health Check
Version : 1.0
Hostname: server01.example.com
Date    : Thu Mar 13
=================================

---- Disk Space ----
OK : Disk usage on / is 45%
OK : Disk usage on /home is 62%

---- Disk Health (SMART) ----
/dev/sda : OK
/dev/sdb : OK

---- RAID Status ----
RAID Status : OK

---- MySQL Backup ----
Latest Backup : mysqlbackup-2026-03-13.tar.gz
Backup Status : OK

=================================
Report completed
=================================
Update Log

Script update activity is recorded at:

/var/log/daily-report-update.log

Example:

2026-03-13 Updated script from 1.0 to 1.1
Supported Systems

Tested on:

CentOS 7

AlmaLinux

Rocky Linux

Debian

Ubuntu

Notes

SMART checks ignore non-physical devices such as loop and ram.

If running via cron, ensure smartctl is accessible in the cron PATH.

Hardware RAID environments may require vendor tools (megacli, storcli) for accurate disk health.

Security Considerations

Only host the update script on a trusted server.

Consider implementing checksum validation for production environments.

