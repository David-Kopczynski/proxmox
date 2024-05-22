# 🌐 Golden-CT

This container has been created using `Ubuntu 23.10` with the following steps:

1. Configure container for `vnet` with IP matching to id
2. Configure container for `vmbr0` for access via router (which can be optionally turned on)
3. Added `Start at boot` flag
4. Added ssh keys found at Bitwarden
5. Configured git with `git config --global user.name "David Kopczynski"` and `git config --global user.email "david.kop.dk@gmail.com"`
6. Cloned this repo
7. Added docker with `apt update && apt upgrade -y && apt install curl -y && curl -fsSL get.docker.com | bash`
