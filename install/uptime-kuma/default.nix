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
      # Allow proxying without overwriting current protocol (modified recommendedProxySettings)
      # This fixes websockets with my `user -> https -> http -> service` setup
      extraConfig = ''
        proxy_set_header Host               $host;
        proxy_set_header X-Real-IP          $remote_addr;
        proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host   $host;
        proxy_set_header X-Forwarded-Server $host;
      '';
      proxyPass = "http://127.0.0.1:${toString config.services.uptime-kuma.settings.PORT}/";
      proxyWebsockets = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
