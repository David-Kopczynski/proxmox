{ ... }:

{
  # Load minimum viable configuration for initial deployment
  imports = [
    ./disko.nix
    ../default.nix
  ];
}
