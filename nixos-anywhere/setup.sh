#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nixos-anywhere
set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "$0")"

# Get target host
read -rp "Host IP: " host
nixos-anywhere --store-paths $(nix-build -A config.system.build.diskoScript -A config.system.build.toplevel --no-out-link) root@"$host"
