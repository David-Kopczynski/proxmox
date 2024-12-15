# 🌐 NixOS on Proxmox

This Nix installation includes all services running on my Proxmox Home-Lab server.
Installation is done remotely via `nixos-rebuild --target-host root@IP_OF_TARGET -I nixos-config=PATH_TO_THIS_REPO` to build and deploy the new configuration.
This way, the server is always up-to-date with the current channels of my private NixOS configuration (latest stable).

Please keep in mind, that data is primarily stored locally on the server within the `/data` directory (which must be added via Proxmox and setup using parted).
The layout of the disks is as follows:

```console
[root@nixos:/home/nixos]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0   24G  0 disk
├─sda1   8:1    0 16.5G  0 part /nix/store
|                               /
├─sda2   8:2    0    7G  0 part [SWAP]
└─sda3   8:3    0  487M  0 part /boot
sdb      8:16   0   32G  0 disk
└─sdb1   8:17   0   32G  0 part /data
```
*Hint: I followed the installation for UEFI (which is not default for Proxmox). At the time of writing, secure boot must be disabled with ESC -> Device Manager -> Secure Boot -> Disable Secure Boot -> Save & Exit.*
*Also, the initial installation requires some extra work to get the first installation up-and-running. For this services.openssh.settings.PermitRootLogin must be enabled.*

#

Credits to [Josh Lee](https://www.joshuamlee.com/nixos-proxmox-vm-images/) for a great guide while setting up this configuration.
Also, see the [Official Documentation](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual) for more information during initial installation.
