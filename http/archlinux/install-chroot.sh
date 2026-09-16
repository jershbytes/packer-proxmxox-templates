#!/bin/bash

set -e
set -x

ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime

echo 'archlinux' > /etc/hostname

sed -i -e 's/^#\(en_US.UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

mkinitcpio -P

echo -e 'packer\npacker' | passwd
useradd -m -U packer
echo -e 'packer\npacker' | passwd packer
cat <<EOF > /etc/sudoers.d/packer
Defaults:packer !requiretty
packer ALL=(ALL) NOPASSWD: ALL
EOF
chmod 440 /etc/sudoers.d/packer

mkdir -p /etc/systemd/network
ln -sf /packer/null /etc/systemd/network/99-default.link

mkdir -p /etc/cloud/cloud.cfg.d
cat <<EOF > /etc/cloud/cloud.cfg.d/99-proxmox.cfg
datasource_list: [ NoCloud ]
EOF

systemctl enable sshd
systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service
systemctl enable qemu-guest-agent.service
systemctl enable cloud-init-local.service
systemctl enable cloud-init-main.service
systemctl enable cloud-init-network.service
systemctl enable cloud-config.service
systemctl enable cloud-final.service

cloud-init clean --logs

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB "$device"
sed -i -e 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=1/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg