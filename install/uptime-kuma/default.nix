{ ... }:
{ config, ... }:

{
  services.uptime-kuma.enable = true;
  services.uptime-kuma = {

    # General configuration
    appriseSupport = true;
    settings.PORT = toString 3000;
  };

  # Nginx reverse proxy to Uptime Kuma with custom port 3000
  imports = [ ../nginx/proxy-pass.websockets.nix ];

  services.nginx.enable = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      extraConfig = config.nginx.proxyWebsocketsConfig;
      proxyPass = "http://127.0.0.1:${toString config.services.uptime-kuma.settings.PORT}/";
      proxyWebsockets = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
