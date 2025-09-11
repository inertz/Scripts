#!/bin/bash
# Revert bond0 configuration and restore individual NICs

set -e

BOND_IF="bond0"
SLAVES=("ens37f0" "ens37f1" "ens31f0" "ens31f1")

echo "[INFO] Deleting bond connection..."
nmcli con del bond-$BOND_IF || true

echo "[INFO] Deleting slave connections..."
for IF in "${SLAVES[@]}"; do
  nmcli con del "bond-slave-$IF" || true
done

echo "[INFO] Restoring each interface with DHCP..."
for IF in "${SLAVES[@]}"; do
  nmcli con add type ethernet ifname "$IF" con-name "$IF" ipv4.method auto
  nmcli con up "$IF"
done

echo "[INFO] Bond reverted, all NICs are now standalone with DHCP."
