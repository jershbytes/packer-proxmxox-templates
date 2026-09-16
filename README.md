# Packer Proxmox VM Templates

This repo contains a small set of Packer templates for building Proxmox VM templates for several Linux distributions. The setup is intentionally opinionated and tuned for a personal Proxmox environment, but it is structured so you can adjust the .pkrvars files and installer files for your own infrastructure.

## Included builds

The repository currently includes configuration for these builds:

- Rocky Linux 10
- Debian 13
- Arch Linux
- Talos 1.12

The actual base builder is defined in [generic.pkr.hcl](generic.pkr.hcl), while OS-specific variables and installer assets live alongside the repo files.

## Repository layout

- [config.pkr.hcl](config.pkr.hcl): required Packer plugin configuration
- [generic.pkr.hcl](generic.pkr.hcl): shared Proxmox source and VM settings
- [variables.pkr.hcl](variables.pkr.hcl): common variable definitions used by all builds
- [*.pkrvars.hcl](./): per-template variable files such as [rocky-10.pkrvars.hcl](rocky-10.pkrvars.hcl), [debian-13.pkrvars.hcl](debian-13.pkrvars.hcl), [archlinux.pkrvars.hcl](archlinux.pkrvars.hcl), and [talos-1.12.pkrvars.hcl](talos-1.12.pkrvars.hcl)
- [http/](http/): kickstart/preseed/autoinstall files and installer scripts used during the build
- [justfile](justfile): convenient commands for common builds

## Prerequisites

- Packer installed locally
- A Proxmox node with API access
- A storage pool for ISO images and templates
- A network bridge configured for the VM NICs

Initialize the required Packer plugin before building:

```bash
packer init config.pkr.hcl
```

## Build flow

This repo uses a generic Proxmox ISO builder and then injects OS-specific installer automation via files in [http/](http/).

The easiest way to build a template is to use the included just recipes:

```bash
just rocky-10
just debian
just talos
just archlinux
```

You can also run Packer directly:

```bash
packer build -var-file=rocky-10.pkrvars.hcl -only=linux.* .
packer build -var-file=debian-13.pkrvars.hcl -only=linux.* .
packer build -var-file=archlinux.pkrvars.hcl -only=linux.* .
packer build -var-file=talos-1.12.pkrvars.hcl -only=linux.* .
```

## Required variables

At minimum, each template needs Proxmox connection details and VM placement values. The actual variables are defined in [variables.pkr.hcl](variables.pkr.hcl), but the common ones include:

- `proxmox_host`
- `proxmox_user`
- `proxmox_password` or `proxmox_token`
- `node`
- `vmid`
- `disk_storage_pool`
- `iso_storage_pool`
- `cloud_init_storage_pool`

The template-specific .pkrvars files set the rest, such as ISO file information, boot commands, and VM metadata.

## HTTP forwarding note

If your Proxmox host is remote and cannot directly reach the machine running Packer, you may need to forward the HTTP listener. The project documentation previously included the SSH tunnel approach; the repo expects the installer to be reachable from the Proxmox host during the build.

## Notes

- These templates are built for a specific environment and may require adjustments for your own storage names, networks, or automation preferences.
- The build process is focused on templated Linux guests, not a broader fleet-management system.
- This repo is best treated as a practical starting point for reproducible Proxmox image generation.

## Credits

This project is based on the broader Proxmox + Packer template pattern that has been shared in the community, adapted here for the author’s own needs and environment.
