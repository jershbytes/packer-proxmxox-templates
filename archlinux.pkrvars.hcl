name           = "archlinux-template"
vmid           = "921"
iso_file       = "archlinux-x86_64.iso"
iso_url        = "https://mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso"
iso_checksum   = "file:https://mirror.rackspace.com/archlinux/iso/latest/sha256sums.txt"
http_directory = "./http/archlinux"
boot_wait      = "10s"
boot_command = [
  "<enter><wait10><wait10><wait10><wait10>",
  "curl -O 'http://{{ .HTTPIP }}:{{ .HTTPPort }}/install{,-chroot}.sh'<enter><wait>",
  "bash install.sh < install-chroot.sh && systemctl reboot<enter>"
]

provisioner = [
  "userdel --remove --force packer"
]