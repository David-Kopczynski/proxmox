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
  users.users.immich.extraGroups = [
    "video"
    "render"
  ];

  # Nginx reverse proxy to Immich with port 2283
  services.nginx.enable = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      extraConfig = ''
        # Allow large file uploads
        client_max_body_size    0;
        proxy_request_buffering off;
        proxy_buffering         off;
      '';
      proxyPass = "http://${config.services.immich.host}:${toString config.services.immich.port}";
    };
    locations."= /api/socket.io/" = {
      inherit (config.services.nginx.virtualHosts."localhost".locations."/")
        proxyPass
        ;
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
