# 🌐 Proxmox

This mono repo contains all `docker-compose.yml` files for various services inside their own folders.

## 🚀 Creating New Containers

When creating new containers, the following steps should be followed:

1. Change IP of `eth0` to `10.0.x.yz/10` with `xyz` being the numbers of the ID
2. Optionally: Activate the `eth1` interface to allow connection from local network
3. Run `echo "cd ~/proxmox/..." >> ~/.bashrc` for a default entrypoint
4. 🐳
