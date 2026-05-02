{ ... }:
{ config, ... }:

{
  services.adguardhome.enable = true;
  services.adguardhome = {

    # General configuration
    host = "127.0.0.1";
  };

  # Nginx reverse proxy to AdGuard-Home with port 3000
  imports = [ ../nginx/proxy-pass.client.nix ];

  services.nginx.enable = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      proxyPass = "http://${config.services.adguardhome.host}:${toString config.services.adguardhome.port}/";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
