# 🌐 NixOS on Proxmox
This Nix installation is for multiple VMs running on my Proxmox Home-Lab server with a N100 (Intel 4 Core, Max 3.40 GHz) and 32 GB of RAM.

Installation is done remotely with the following command to build and deploy the new configuration.

```shell
nix-shell -p colmena --run "colmena apply -f PATH_TO_THIS_REPO/hive.nix [switch|test] [--on <NODES>]"
```

This way, the server is always up-to-date with the current channels (`nixos`, `sops-nix`) of my private NixOS configuration. \
Proxmox itself and the Proxmox-Backup-Server is kept updated with Ansible.

```shell
./ansible/update.sh
```

<details>
<summary>🔨 Installation</summary>

Setup is done remotely using `nixos-anywhere` by running `./nixos-anywhere/setup.sh` to setup all partitions and deploying a base configuration to begin with.

Make sure the following constraints are met:

1. The VM is created with the following settings:
    - Memory: **4 GB** (4096 MB)
    - BIOS: OVMF (**UEFI**)
    - Hard Disk (scsi0): **8 GB**
    - Hard Disk (scsi1): **1 GB**
    - EFI Disk: ***default***
2. The VM is booted with the NixOS installation ISO.
3. A **password is set** with `sudo passwd` to connect with the VM over SSH.
4. Install using `./nixos-anywhere/setup.sh`.
5. After installation, a **new password** should be set with `passwd`. Apart from that, the VM is ready to be used, while the **ISO can be removed**. Ideally, the VM should also be renamed to its hostname within the router dashboard.
6. In order to deploy with Colmena, the initial installation with `deployment.targetHost` should point to the hostname `nixos` or the IP address of the VM. Also, (if required) generate an `age` key for the host machine with `nix-shell -p ssh-to-age --run "echo '$(ssh root@nixos "cat /etc/ssh/ssh_host_ed25519_key.pub")' | ssh-to-age"` and add it to the `.sops.yaml` file.

*Otherwise, the installation will fail due to a lack of resources in the store or the connection being refused.* \
*During the installation, it is possible for the IP to change. If this happens, run the installation again using the new IP.*

*At the time of writing, secure boot must be disabled with `ESC -> Device Manager -> Secure Boot Configuration -> Disable Secure Boot -> Save & Exit` (enter by pressing ESC while booting VM).*

</details>

<details>
<summary>🔐 Secrets</summary>

Secrets are encrypted with [`sops`](https://github.com/Mic92/sops-nix/) using my private SSH key.

```shell
cd PATH_TO_THIS_REPO
nix-shell -p sops --run "sops install/$HOST/secrets.yaml"
```

*During creation of the `secrets.yaml`, you need to `cd` into this directory to create the file.* \
*Afterwards, you can open the file from anywhere.*

</details>

---

Credits to [Josh Lee](https://www.joshuamlee.com/nixos-proxmox-vm-images/) for a great guide while setting up this configuration.
