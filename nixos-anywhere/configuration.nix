{ hasDataDisk, ... }:

{
  # Load minimum viable configuration for initial deployment
  imports = [
    (import ../default.nix { inherit hasDataDisk; })
    ./disko.nix
  ];
}
