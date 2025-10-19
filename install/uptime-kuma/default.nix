{ ... }:
{ config, ... }:

{
  services.uptime-kuma.enable = true;
  services.uptime-kuma = {

    # General configuration
    settings.HOST = "127.0.0.1";
    settings.PORT = toString 3000;

    appriseSupport = true;
  };

  # Nginx reverse proxy to Uptime Kuma with custom port 3000
  imports = [ ../nginx/proxy-pass.websockets.nix ];

  services.nginx.enable = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      extraConfig = config.nginx.proxyWebsocketsConfig;
      proxyPass = "http://${config.services.uptime-kuma.settings.HOST}:${toString config.services.uptime-kuma.settings.PORT}/";
      proxyWebsockets = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
