#!/bin/bash
# Setup bond0 with 4 NICs and 2 IP addresses on AlmaLinux 9

set -e

BOND_IF="bond0"
SLAVES=("ens37f0" "ens37f1" "ens31f0" "ens31f1")
IPV4_ADDRS="10.10.10.116/24,10.10.10.117/24"
GATEWAY="10.10.10.1"

echo "[INFO] Stopping and deleting old bond connections if any..."
nmcli con show | grep -E "bond0|ens37f0|ens37f1|ens31f0|ens31f1" | awk '{print $1}' | while read -r con; do
  nmcli con del "$con" || true
done

echo "[INFO] Creating bond interface: $BOND_IF..."
nmcli con add type bond ifname $BOND_IF mode 802.3ad

echo "[INFO] Setting bonding options..."
nmcli con mod bond-$BOND_IF +bond.options "miimon=100,updelay=200,downdelay=200"

echo "[INFO] Adding slave interfaces..."
for IF in "${SLAVES[@]}"; do
  nmcli con add type ethernet ifname "$IF" master $BOND_IF
done

echo "[INFO] Configuring IP addresses and gateway..."
nmcli con mod bond-$BOND_IF ipv4.method manual ipv4.addresses "$IPV4_ADDRS" ipv4.gateway "$GATEWAY" ipv4.dns "8.8.8.8 1.1.1.1"

echo "[INFO] Bringing up bond interface..."
nmcli con up bond-$BOND_IF

echo "[INFO] Bond setup complete."
echo "Check bond status: cat /proc/net/bonding/$BOND_IF"
echo "Check IP: ip a show $BOND_IF"
