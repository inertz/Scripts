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

