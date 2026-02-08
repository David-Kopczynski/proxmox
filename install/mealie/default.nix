{ domain }:
{ config, ... }:

{
  services.mealie.enable = true;
  services.mealie = {

    # General configuration
    settings."BASE_URL" = "https://${domain}";

    # Database optimization
    database.createLocally = true;
  };

  # Nginx reverse proxy to Mealie with port 9000
  imports = [ ../nginx/proxy-pass.websockets.nix ];

  services.nginx.enable = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      extraConfig = config.nginx.proxyWebsocketsConfig;
      proxyPass = "http://${config.services.mealie.listenAddress}:${toString config.services.mealie.port}/";
      proxyWebsockets = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
