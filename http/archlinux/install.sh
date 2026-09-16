#!/bin/bash

set -e
set -x

if [ -e /dev/vda ]; then
  device=/dev/vda
elif [ -e /dev/sda ]; then
  device=/dev/sda
else
  echo "ERROR: There is no disk available for installation" >&2
  exit 1
fi
export device

memory_size_in_kilobytes=$(free | awk '/^Mem:/ { print $2 }')
swap_size_in_kilobytes=$((memory_size_in_kilobytes * 2))
max_swap_size_in_kilobytes=$((2 * 1024 * 1024))
if [ "$swap_size_in_kilobytes" -gt "$max_swap_size_in_kilobytes" ]; then
  swap_size_in_kilobytes=$max_swap_size_in_kilobytes
fi
sfdisk "$device" <<EOF
label: gpt
size=512MiB, type=uefi
size=${swap_size_in_kilobytes}KiB, type=swap
                                   type=linux
EOF

blockdev --rereadpt "$device" || true
udevadm settle
if [ ! -b "${device}1" ] || [ ! -b "${device}2" ] || [ ! -b "${device}3" ]; then
  echo "ERROR: Partition devices were not created for ${device}" >&2
  lsblk "$device" >&2
  exit 1
fi
mkfs.fat -F 32 "${device}1"
mkswap "${device}2"
mkfs.ext4 "${device}3"
mount "${device}3" /mnt
mkdir -p /mnt/boot/efi
mount "${device}1" /mnt/boot/efi

# Get some US mirrors just to install reflector, which will rank the mirrors
# by speed before intalling the rest of the packages
curl -fsSL 'https://archlinux.org/mirrorlist/?country=US&protocol=https&ip_version=4' > /tmp/mirrorlist
grep '^#Server' /tmp/mirrorlist | sort -R | head -n 50 | sed 's/^#//' > /etc/pacman.d/mirrorlist
if [ ! -s /etc/pacman.d/mirrorlist ]; then
  echo "ERROR: Arch mirror list is empty" >&2
  exit 1
fi
pacman -Sy --noconfirm
pacman -S reflector --noconfirm
reflector --verbose --country US --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Install base packages, just enough for a basic system
pacman -Sy --noconfirm
pacstrap /mnt base base-devel linux grub efibootmgr dosfstools openssh sudo qemu-guest-agent cloud-init dhcpcd vim
swapon "${device}2"
genfstab -p /mnt >> /mnt/etc/fstab
swapoff "${device}2"

arch-chroot /mnt /bin/bash