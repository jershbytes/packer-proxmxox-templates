name           = "talos-template"
vmid           = 912
iso_file       = "archlinux-x86_64.iso"
iso_url        = "https://dfw.mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso"
iso_checksum   = "file:https://dfw.mirror.rackspace.com/archlinux/iso/latest/sha256sums.txt"
http_directory = "./http/talos"
ssh_username   = "root"
boot_wait      = "5s"
boot_command = [
    "<enter><wait1m>",
    "passwd<enter><wait>packer<enter><wait>packer<enter>",
]
provisioner = [
    "curl -L http://$PACKER_HTTP_IP:$PACKER_HTTP_PORT/schematic.yaml -o schematic.yaml",
    "export SCHEMATIC=$(curl -L -X POST --data-binary @schematic.yaml https://factory.talos.dev/schematics | grep -o '\"id\":\"[^\"]*' | grep -o '[^\"]*$')",
    # renovate: githubReleaseVar repo=siderolabs/talos
    "curl -L https://factory.talos.dev/image/$SCHEMATIC/v1.12.6/nocloud-amd64.raw.xz -o /tmp/talos.raw.xz",
    "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda && sync"
]
