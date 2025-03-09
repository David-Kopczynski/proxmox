import (<nixpkgs> + "/nixos/lib/eval-config.nix") { modules = [ ./configuration.nix ]; }
