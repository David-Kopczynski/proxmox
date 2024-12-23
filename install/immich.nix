{ config, ... }:

let
  HOST = "photos.davidkopczynski.com";
  DATA = /data/immich;
in
{
  services.immich.enable = true;
  services.immich.mediaLocation = toString DATA;
  services.immich.secretsFile = toString (DATA + ./secrets.env);

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
      proxyPass = "http://localhost:${toString config.services.immich.port}";
      proxyWebsockets = true;
    };
  };
}
