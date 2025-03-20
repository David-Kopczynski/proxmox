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
          (import ./install/${name} ({ domain = config.system.name; } // args))
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
  #       Reverse Proxy for All Other Services        #
  # # # # # # # # # # # # # # # # # # # # # # # # # # #
  nginx =
    args@{ lib, nodes, ... }:
    {
      system.stateVersion = "24.11";

      imports =
        # Merge all nginx related configurations from the other services
        lib.trivial.pipe nodes [
          (x: lib.attrsToList (removeAttrs x [ "nginx" ]))
          (map (
            n:
            import ./install/nginx/proxy-pass.nix (
              {
                cloudflare = builtins.elem "cloudflare" n.value.config.deployment.tags;
                default = builtins.elem "default" n.value.config.deployment.tags;
                domain = n.value.config.system.name;
                targetHost = n.value.config.deployment.targetHost;
              }
              // args
            )
          ))
        ];
    };

  # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #                Special Purpose VMs                #
  # # # # # # # # # # # # # # # # # # # # # # # # # # #
  stirling-pdf = {
    system.name = "pdf.davidkopczynski.com";
    system.stateVersion = "24.11";

    deployment.tags = [ ];
  };
}
