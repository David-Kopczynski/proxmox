# 🌐 Proxmox

This mono repo contains all `docker-compose.yml` files used and setup descriptions for the golden image. 

Currently, this repo contains:

| Branch | Description |
| --- | --- |
| [golden-ct](/David-Kopczynski/proxmox/tree/master) | Golden image "container" that includes Docker and this repo preinstalled |

## 🚀 Creating New Containers

When creating new containers, the following steps should be followed:

1. Change IP of `eth0` to `10.0.x.yz/24` with `xyz` being the numbers of the ID
2. Optionally: Activate the `eth1` interface to allow connection from local network
3. Get started with a new branch using Docker! 🐳
