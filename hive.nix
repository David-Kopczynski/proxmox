{
  meta.nixpkgs = <nixpkgs>;

  # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #                  Default Config                   #
  # # # # # # # # # # # # # # # # # # # # # # # # # # #
  defaults =
    {
      config,
      lib,
      name,
      ...
    }:
    {
      imports =
        # Node specific configuration
        [
          (import ./install/${name} { domain = config.system.name; })
          (import ./default.nix { hasDataDisk = builtins.elem "data" config.deployment.tags; })
        ]
        ++
          # Secrets management (if provided)
          lib.lists.optional (builtins.pathExists ./install/${name}/secrets.yaml) (
            import ./sops/default.nix { sopsFile = ./install/${name}/secrets.yaml; }
          );

      # Networking target host
      deployment.targetHost = lib.mkDefault config.networking.hostName;
      networking.hostName = name;
    };

  # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #       Reverse Proxy for All Other Services        #
  # # # # # # # # # # # # # # # # # # # # # # # # # # #
  nginx =
    { lib, nodes, ... }:
    {
      system.stateVersion = "24.11";

      imports =
        # Merge all nginx related configurations from the other services
        lib.trivial.pipe nodes [
          (x: lib.attrsToList (removeAttrs x [ "nginx" ]))
          (x: builtins.filter (n: !builtins.elem "standalone" n.value.config.deployment.tags) x)
          (map (
            n:
            import ./install/nginx/proxy-pass.nix {
              cloudflare = builtins.elem "cloudflare" n.value.config.deployment.tags;
              default = builtins.elem "default" n.value.config.deployment.tags;
              domain = n.value.config.system.name;
              targetHost = n.value.config.deployment.targetHost;
            }
          ))
        ]
        # Include additional stateless nginx configurations
        ++ lib.trivial.pipe (builtins.readDir ./install/nginx) [
          (x: builtins.filter (n: x.${n} == "directory") (builtins.attrNames x))
          (builtins.filter (n: builtins.pathExists ./install/nginx/${n}/default.nix))
          (builtins.map (n: import ./install/nginx/${n}/default.nix { domain = n; }))
        ];
    };

  # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #                Special Purpose VMs                #
  # # # # # # # # # # # # # # # # # # # # # # # # # # #
  immich = {
    system.name = "photos.davidkopczynski.com";
    system.stateVersion = "24.11";

    deployment.tags = [ "data" ];
  };
  mealie = {
    system.name = "meals.davidkopczynski.com";
    system.stateVersion = "25.11";

    deployment.tags = [ ];
  };
  minecraft = {
    system.name = "minecraft.davidkopczynski.com";
    system.stateVersion = "25.05";

    deployment.tags = [ "standalone" ];
  };
  nextcloud = {
    system.name = "cloud.davidkopczynski.com";
    system.stateVersion = "24.11";

    deployment.tags = [ "data" ];
  };
  octoprint = {
    system.name = "printer.davidkopczynski.com";
    system.stateVersion = "24.11";

    deployment.tags = [ "data" ];
  };
  paperless = {
    system.name = "archive.davidkopczynski.com";
    system.stateVersion = "24.11";

    deployment.tags = [ ];
  };
  stirling-pdf = {
    system.name = "pdf.davidkopczynski.com";
    system.stateVersion = "24.11";

    deployment.tags = [ ];
  };
  uptime-kuma = {
    system.name = "davidkopczynski.com";
    system.stateVersion = "24.11";

    deployment.tags = [ "default" ];
  };
}
