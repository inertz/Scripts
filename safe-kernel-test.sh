#!/bin/bash

# Enable panic auto-reboot after 10 seconds
echo "Setting kernel.panic = 10"
echo "kernel.panic = 10" >> /etc/sysctl.conf
sysctl -p

# Configure GRUB to use saved/default fallback logic
echo "Configuring GRUB fallback behavior"
sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub
sed -i '/^GRUB_SAVEDEFAULT=/d' /etc/default/grub
echo "GRUB_SAVEDEFAULT=true" >> /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

# Show available kernels
echo "📦 Available GRUB menu entries:"
awk -F\' '/^menuentry / {print "[" NR-1 "] " $2}' /boot/grub2/grub.cfg

# Ask user for kernel index to test
read -p "Enter the kernel index to test temporarily (e.g. 0 or 1): " index

# Set grub to boot this kernel only once
grub2-reboot $index
echo "✅ Next reboot will boot kernel index $index ONCE"

# Optional systemd service to mark successful boot
cat <<EOF > /etc/systemd/system/mark-boot-success.service
[Unit]
Description=Mark GRUB default after successful boot
DefaultDependencies=no
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/grub2-set-default 0

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl enable mark-boot-success.service

echo "✅ Boot marking service installed"

# Final confirmation
echo "✅ Setup complete. Reboot now to test kernel $index."
echo "👉 If it panics, system will auto-reboot into previous working kernel."
