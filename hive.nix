{
  meta.nixpkgs = <nixpkgs>;

  # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #                  Default Config                   #
  # # # # # # # # # # # # # # # # # # # # # # # # # # #
  defaults =
    args@{ config, name, ... }:
    {
      imports = [
        # Node specific configuration
        ./install/${name}

        # General configuration (with tweaks)
        (import ./default-configuration.nix (
          {
            hasDataDisk = builtins.elem "data" config.deployment.tags;
          }
          // args
        ))
      ];

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
