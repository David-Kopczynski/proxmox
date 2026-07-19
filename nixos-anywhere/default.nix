{
  # Custom arguments
  hasDataDisk ? false,
}:

import "${(import ../npins).nixpkgs}/nixos/lib/eval-config.nix" {

  modules = [ ./configuration.nix ];
  specialArgs = { inherit hasDataDisk; };
}
