# 🌐 NixOS on Proxmox

This Nix installation is for multiple VMs running on my Proxmox Home-Lab server with a N100 (Intel 4 Core, Max 3.40 GHz) and 32 GB of RAM.

Installation is done remotely with the following command to build and deploy the new configuration.

```shell
???
```

This way, the server is always up-to-date with the current channels of my private NixOS configuration (latest stable).

<details>
<summary>🔨 Installation</summary>

Setup is done remotely using `nixos-anywhere` by running `nix-shell PATH_TO_THIS_REPO/nixos-anywhere/setup.sh` to setup all partitions and deploying a base configuration to begin with.

Make sure the following constraints are met:

1. The VM is created with the following settings:
    - Memory: **4 GB** (4096 MB)
    - BIOS: OVMF (**UEFI**)
    - Hard Disk (scsi0): **8 GB**
    - Hard Disk (scsi1): **1 GB**
    - EFI Disk: ***default***
2. The VM is booted with the NixOS installation ISO.
3. A **password is set** with `passwd` to connect with the VM over SSH.
4. Install using `nix-shell PATH_TO_THIS_REPO/nixos-anywhere/setup.sh`.
5. After installation, a **new password** should be set with `passwd`. Apart from that, the VM is ready to be used, while the **ISO can be removed**.

*Otherwise, the installation will fail due to a lack of resources in the store or the connection being refused.*

*At the time of writing, secure boot must be disabled with `ESC -> Device Manager -> Secure Boot Configuration -> Disable Secure Boot -> Save & Exit` (enter by spamming ESC while booting VM).*

</details>

---

Credits to [Josh Lee](https://www.joshuamlee.com/nixos-proxmox-vm-images/) for a great guide while setting up this configuration.
