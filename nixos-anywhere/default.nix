import (<nixpkgs> + "/nixos/lib/eval-config.nix") {

  # Load configuration for deployment
  modules = [
    ./disko.nix
    ../default-configuration.nix
  ];
}
