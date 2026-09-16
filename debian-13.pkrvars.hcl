# renovate: datasource=custom.debianLinuxRelease
name           = "debian-13-template"
vmid           = "920"
iso_file       = "debian-13.4.0-amd64-netinst.iso"
iso_url        = "https://cdimage.debian.org/mirror/cdimage/archive/13.4.0/amd64/iso-cd/debian-13.4.0-amd64-netinst.iso"
iso_checksum   = "file:https://cdimage.debian.org/mirror/cdimage/archive/13.4.0/amd64/iso-cd/SHA256SUMS"
http_directory = "./http/debian"
boot_command = [
        "<wait3>c<wait3>",
        "linux /install.amd/vmlinuz auto-install/enable=true priority=critical ",
        "DEBIAN_FRONTEND=text preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg noprompt<enter>",
        "initrd /install.amd/initrd.gz<enter>",
        "boot<enter>"
    ]
provisioner = [
  "userdel --remove --force packer"
]