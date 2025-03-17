{
  meta.nixpkgs = <nixpkgs>;

  # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #                  Default Config                   #
  # # # # # # # # # # # # # # # # # # # # # # # # # # #
  defaults =
    args@{
      config,
      lib,
      name,
      ...
    }:
    {
      imports =
        # Node specific configuration
        [
        ./install/${name}
          (import ./default.nix ({ hasDataDisk = builtins.elem "data" config.deployment.tags; } // args))
        ]
        ++
        # Secrets management (if provided)
        lib.lists.optional (builtins.pathExists ./install/${name}/secrets.yaml) (
          import ./sops/default.nix ({ sopsFile = ./install/${name}/secrets.yaml; } // args)
        );

      # Networking target host
      deployment.targetHost = config.networking.hostName;
      networking.hostName = name;
    };

  # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #                Special Purpose VMs                #
  # # # # # # # # # # # # # # # # # # # # # # # # # # #
  stirling-pdf = {
    system.stateVersion = "24.11";

    deployment.tags = [ ];
  };
}
