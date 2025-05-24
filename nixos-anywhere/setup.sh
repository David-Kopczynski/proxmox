#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nix nixos-anywhere
set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "$0")"

# Get target host and configuration
read -rp "Host IP: " host
read -rp "Has Data Disk? [y/N]: " has_data_disk

case "$has_data_disk" in
  [Yy]*) has_data_disk=true ;;
  *)     has_data_disk=false ;;
esac

nixos-anywhere --store-paths $(nix-build --arg hasDataDisk $has_data_disk -A config.system.build.diskoScript -A config.system.build.toplevel --no-out-link) root@"$host"
