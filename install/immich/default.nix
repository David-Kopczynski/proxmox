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
      # Allow proxying without overwriting current protocol (modified recommendedProxySettings)
      # This fixes websockets with my `user -> https -> http -> service` setup
      extraConfig = ''
        proxy_set_header Host               $host;
        proxy_set_header X-Real-IP          $remote_addr;
        proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host   $host;
        proxy_set_header X-Forwarded-Server $host;

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
