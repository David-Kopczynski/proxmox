{ config, ... }:

let
  HOST = "photos.davidkopczynski.com";
  DATA = /data/immich;
in
{
  services.immich.enable = true;
  services.immich.host = "127.0.0.1";
  services.immich.mediaLocation = toString (DATA + "/media");
  services.immich.secretsFile = toString (DATA + "/secrets.env");

  # Enable hardware acceleration
  users.users.immich.extraGroups = [
    "video"
    "render"
  ];

  # Nginx reverse proxy to Immich with port 2283
  services.nginx.virtualHosts.${HOST} = {

    enableACME = true;
    forceSSL = true;
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
      inherit (config.services.nginx.virtualHosts.${HOST}.locations."/")
        proxyPass
        ;
      proxyWebsockets = true;
    };
  };
}
