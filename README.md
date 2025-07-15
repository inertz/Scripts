# Welcome to My GitHub Scripts Repository
---
This GitHub Page showcases a collection of personal scripts and tools I have developed. These scripts are designed to streamline tasks, automate processes, and provide solutions to common challenges in software development, server management, and system configuration.

## What You’ll Find Here
- **Automation Scripts**: Tools for simplifying repetitive tasks like backups, data processing, and system monitoring.
- **Server Configuration**: Scripts for setting up and optimizing web servers (e.g., Apache, cPanel DNS).
- **Custom Utilities**: Personalized tools tailored to address unique challenges in system administration and web development.
- **Networking Solutions**: Scripts for managing network configurations, including IP whitelisting and Netplan setups.

## Purpose
The purpose of this repository is to:
1. Share knowledge and resources with the developer community.
2. Document my learning journey and experiences in programming and system administration.
3. Provide reusable scripts for quick integration into projects.

## Get Started
Explore the scripts in the repository and feel free to contribute, report issues, or suggest enhancements!

## Contact Me
For feedback, inquiries, or collaboration opportunities, reach out to me via email or [GitHub Discussions](#).

---
<!-- TOC -->
1. [createtp.sh](createtp.sh) will create KVM template but only for below OS;
* Available OS templates:
* alma-8.5                 x86_64     AlmaLinux 8.5
* centos-7.8               x86_64     CentOS 7.8
* centos-8.2               x86_64     CentOS 8.2
* debian-12                x86_64     Debian 12 (bookworm)
* ubuntu-20.04             x86_64     Ubuntu 20.04 (focal)
* fedora-32                x86_64     Fedora® 32 Server


<!-- TOC -->
---
2. [snapshot.sh](snapshot.sh) will create a snapshot of the VM. It can be used as a cronjob.

Sample command:
```shell
[root@vz ~]# ./snapshot.sh
Domain snapshot alma8 2023-10-11-15:20 created
Domain snapshot alma81 2023-10-11-15:20 created
Domain snapshot opensuse 2023-10-11-15:20 created
```
<!-- TOC -->
---
3. This [get_pod_logs.sh](get_pod_logs.sh) Bash script retrieves the logs of a specified Kubernetes pod in the "openstack" namespace using MicroK8s.

* Open your terminal.
* Create a new bash script file. For example, you can name it 'get_pod_logs.sh'
* Make the script executable
* Now you can use the script to get the logs of any pod by providing the pod name as an argument. For example, to get the logs of a pod named example-pod, you would run:
```shell
./get_pod_logs.sh example-pod
```

<!-- TOC -->
---
4. The [add_ssl_certificate.sh](add_ssl_certificate.sh) script automates the process of obtaining and configuring SSL certificates for domains using Let's Encrypt.

Features
* Requests SSL certificates for specified domains.
* Automatically updates the Apache ssl.conf with the new domain's configuration.
* Backs up the existing configuration before modifications.
* Validates the Apache configuration.
* Restarts Apache to apply changes.

Usage
* Ensure you have Certbot installed and Apache is configured.
* Prepare a file named domains.txt containing the domains you want to secure, one per line.
* Run the script with sudo privileges if you use Ubuntu.
* Follow the prompts or verify the output for any errors.
```shell
sudo ./add_ssl_certificate.sh
```

Requirements
* Certbot installed (apt-get install certbot or yum install certbot).
* Apache web server installed and running.
* Access to edit /etc/httpd/conf.d/ssl.conf.

<!-- TOC -->
---
5. The [remove_ssl_certificate.sh](remove_ssl_certificate.sh) script facilitates the removal of SSL certificates for domains and cleans up Apache configurations.

Features
* Deletes the SSL certificate for the specified domain.
* Removes associated configuration entries in ssl.conf.
* Deletes additional configuration files related to the domain in /etc/httpd/conf.d/.
* Backs up the ssl.conf file for safety.
* Validates the updated Apache configuration.
* Restarts Apache to apply the changes.

Usage
* Run the script with sudo privileges if you use Ubuntu.
* Enter the domain name when prompted (e.g., domain.com).
* The script handles certificate deletion and Apache configuration cleanup automatically.
```shell
sudo ./remove_ssl_certificate.sh
```

Requirements
* Certbot installed
* Apache web server installed and running.
* Access to /etc/httpd/conf.d/ and /etc/letsencrypt/ directories.

<!-- TOC -->
---
6. Manual Linux Kernel Build Script for CentOS 7 [compile-kernel.sh](compile-kernel.sh)

This script helps you manually compile and install a custom Linux kernel on CentOS 7 systems.

It is designed for:
- Learning purposes or patching custom kernel modules



 ⚙️ Features

- Downloads and extracts the desired Linux kernel version
- Reuses current kernel configuration (`/boot/config-*`)
- Compiles kernel and modules using all CPU cores
- Installs modules and kernel into `/boot`
- Regenerates GRUB2 boot configuration
- Sets new kernel as default boot entry

---
<!-- TOC -->
---
7. Safe Kernel Boot Test Script [safe-kernel-test.sh](safe-kernel-test.sh)

This script allows you to **safely test a new Linux kernel** on CentOS 7 by configuring:

- ✅ Auto-reboot after kernel panic
- ✅ GRUB to boot the test kernel only once
- ✅ Automatic fallback to a working kernel if the new one fails
- ✅ Automatic marking of successful boots using `systemd`



 ⚙️ What It Does

- Sets `kernel.panic = 10` to auto-reboot 10 seconds after a kernel panic.
- Configures GRUB to use saved/default boot entry logic.
- Uses `grub2-reboot` to boot into a selected kernel **once**.
- Sets up a `systemd` service (`mark-boot-success`) to **mark the boot as successful** if the system reaches multi-user mode.

---






