#!/bin/bash
# Change to working directory
cd /usr/src || exit 1

# Define kernel version
KVER="6.1.96"

# Download and extract kernel source
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KVER.tar.xz
tar -xf linux-$KVER.tar.xz
cd linux-$KVER || exit 1

# Reuse current kernel config
cp /boot/config-$(uname -r) .config
yes "" | make oldconfig

# Compile kernel and modules (long task)
make -j$(nproc)
make modules_install
make install

# Update GRUB config
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0

echo "✅ Kernel $KVER installed. Reboot to apply."
