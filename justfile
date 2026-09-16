# List available recipes
default: 
    @just --list

# Build RockyLinux 10 Template
rocky-10:
    packer init config.pkr.hcl
    packer build -var-file=rocky-10.pkrvars.hcl -only=linux.* .

# Build Debian 13 Template
debian:
    packer init config.pkr.hcl
    packer build -var-file=debian-13.pkrvars.hcl -only=linux.* .
        
# Build Talos Template
talos:
    packer init config.pkr.hcl
    packer build -var-file=talos-1.12.pkrvars.hcl -only=linux.* . 

# Build Arch Linux Template
archlinux:
    packer init config.pkr.hcl
    packer build -var-file=archlinux.pkrvars.hcl -only=linux.* .