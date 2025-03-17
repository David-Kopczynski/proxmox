{
  # Custom arguments
  hasDataDisk ? false,
}:

import (<nixpkgs> + "/nixos/lib/eval-config.nix") {
  modules = [ ./configuration.nix ];
  specialArgs = { inherit hasDataDisk; };
}
