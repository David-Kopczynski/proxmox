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
  services.nginx.enable = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.uptime-kuma.settings.PORT}";
    };
    locations."= /socket.io/" = {
      inherit (config.services.nginx.virtualHosts."localhost".locations."/")
        proxyPass
        ;
      proxyWebsockets = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
