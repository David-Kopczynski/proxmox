{ ... }:
{ config, ... }:

{
  services.immich.enable = true;
  services.immich = {

    # General configuration
    host = "0.0.0.0";
    mediaLocation = toString /data;
    secretsFile = config.sops.templates."environment".path;
  };

  # Enable hardware acceleration
  users.users.immich.extraGroups = [ "video" ] ++ [ "render" ];

  # Nginx reverse proxy to Immich with port 2283
  imports = [ ../nginx/proxy-pass.websockets.nix ];

  services.nginx.enable = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      extraConfig = ''
        ${config.nginx.proxyWebsocketsConfig}

        client_max_body_size 0;
      '';
      proxyPass = "http://${config.services.immich.host}:${toString config.services.immich.port}/";
      proxyWebsockets = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  # Secrets
  sops.secrets."db/password" = {
    owner = "immich";
    group = "immich";
  };
  sops.templates."environment" = {
    content = ''
      DB_PASSWORD: ${config.sops.placeholder."db/password"}
    '';
    owner = "immich";
    group = "immich";
  };
}
