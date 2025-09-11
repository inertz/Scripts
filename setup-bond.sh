#!/bin/bash
# AlmaLinux Bonding Setup Script
# Bonds ens37f0 + ens37f1 into bond0 with static IP

BOND_NAME="bond0"
BOND_MODE="802.3ad"        # Use "active-backup" if switch not configured for LACP
IP_ADDR="10.10.10.116/24"
GATEWAY="10.10.10.1"

echo "[INFO] Stopping NetworkManager connections for ens37f0 & ens37f1..."
nmcli con modify ens37f0 ipv4.method disabled ipv6.method ignore || true
nmcli con modify ens37f1 ipv4.method disabled ipv6.method ignore || true

echo "[INFO] Deleting existing bond if it exists..."
nmcli con delete $BOND_NAME 2>/dev/null || true
nmcli con delete ${BOND_NAME}-slave-ens37f0 2>/dev/null || true
nmcli con delete ${BOND_NAME}-slave-ens37f1 2>/dev/null || true

echo "[INFO] Creating bond interface: $BOND_NAME in mode $BOND_MODE..."
nmcli con add type bond ifname $BOND_NAME con-name $BOND_NAME mode $BOND_MODE

echo "[INFO] Adding slave interfaces..."
nmcli con add type bond-slave ifname ens37f0 con-name ${BOND_NAME}-slave-ens37f0 master $BOND_NAME
nmcli con add type bond-slave ifname ens37f1 con-name ${BOND_NAME}-slave-ens37f1 master $BOND_NAME

echo "[INFO] Configuring IP & Gateway on $BOND_NAME..."
nmcli con modify $BOND_NAME ipv4.addresses $IP_ADDR
nmcli con modify $BOND_NAME ipv4.gateway $GATEWAY
nmcli con modify $BOND_NAME ipv4.method manual
nmcli con modify $BOND_NAME connection.autoconnect yes

echo "[INFO] Bringing up bond interface..."
nmcli con up $BOND_NAME

echo "[INFO] Bond setup complete."
echo "Check bond status with: cat /proc/net/bonding/$BOND_NAME"
echo "Check IP with: ip a show $BOND_NAME"
