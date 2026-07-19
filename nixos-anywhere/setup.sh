#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nix nixos-anywhere

# Get target host and configuration
read -rp "Host IP: " host
read -rp "Has Data Disk? [y/N]: " has_data_disk

case "$has_data_disk" in
  [Yy]*) has_data_disk=true ;;
  *)     has_data_disk=false ;;
esac

nixos-anywhere \
  --store-paths $(
    nix-build \
      "$(dirname "$0")" \
      --arg hasDataDisk $has_data_disk \
      -A config.system.build.diskoScript \
      -A config.system.build.toplevel \
      --no-out-link
    ) \
  root@"$host"
