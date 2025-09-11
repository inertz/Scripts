#!/bin/bash
# AlmaLinux Bonding Revert Script
# Removes bond0 and restores ens37f0 with original IP

BOND_NAME="bond0"
OLD_IP="10.10.10.110/24"
GATEWAY="10.10.10.1"

echo "[INFO] Deleting bond interface and slaves..."
nmcli con delete $BOND_NAME 2>/dev/null || true
nmcli con delete ${BOND_NAME}-slave-ens37f0 2>/dev/null || true
nmcli con delete ${BOND_NAME}-slave-ens37f1 2>/dev/null || true

echo "[INFO] Re-enabling ens37f0 with IP $OLD_IP..."
nmcli con delete ens37f0 2>/dev/null || true
nmcli con add type ethernet ifname ens37f0 con-name ens37f0
nmcli con modify ens37f0 ipv4.addresses $OLD_IP
nmcli con modify ens37f0 ipv4.gateway $GATEWAY
nmcli con modify ens37f0 ipv4.method manual
nmcli con modify ens37f0 connection.autoconnect yes

echo "[INFO] Re-enabling ens37f1 without IP..."
nmcli con delete ens37f1 2>/dev/null || true
nmcli con add type ethernet ifname ens37f1 con-name ens37f1
nmcli con modify ens37f1 ipv4.method disabled ipv6.method ignore
nmcli con modify ens37f1 connection.autoconnect no

echo "[INFO] Bringing up ens37f0..."
nmcli con up ens37f0

echo "[INFO] Revert complete."
echo "Check IP with: ip a show ens37f0"
