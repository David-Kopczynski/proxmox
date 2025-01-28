# 🌐 NixOS on Proxmox

This Nix installation includes all services running on my Proxmox Home-Lab server with a N100 (Intel 4 Core, Max 3.40 GHz) and 32 GB of RAM.

Installation is done remotely with the following command to build and deploy the new configuration.

```console
  nixos-rebuild --target-host root@IP_OF_TARGET -I nixos-config=PATH_TO_THIS_REPO switch
```

This way, the server is always up-to-date with the current channels of my private NixOS configuration (latest stable).

Please keep in mind, that data is primarily stored locally on the server within the `/data` directory (which must be added via Proxmox and setup using parted). \
The layout of the disks is as follows:

```console
[root@nixos:/home/nixos]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0   40G  0 disk
├─sda1   8:1    0 32.5G  0 part ...
|                               /nix/store
|                               /
├─sda2   8:2    0    7G  0 part [SWAP]
└─sda3   8:3    0  487M  0 part /boot
sdb      8:16   0   32G  0 disk
└─sdb1   8:17   0   32G  0 part /data
sdc      8:32   0  128G  0 disk
└─sdc1   8:33   0  128G  0 part /data/nextcloud
sdd      8:48   0  512G  0 disk
└─sdd1   8:49   0  512G  0 part /data/immich
```
*Hint: I followed the installation for UEFI (which is not default for Proxmox). At the time of writing, secure boot must be disabled with `ESC -> Device Manager -> Secure Boot -> Disable Secure Boot -> Save & Exit`.* \
*Also, the initial installation requires some extra work to get the first installation up-and-running. For this services.openssh.settings.PermitRootLogin must be enabled.*

---

Credits to [Josh Lee](https://www.joshuamlee.com/nixos-proxmox-vm-images/) for a great guide while setting up this configuration. \
Also, see the [Official Documentation](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual) for more information during initial installation.
