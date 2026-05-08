{ domain }:
{ config, ... }:

{
  # Allow access to dashboard from outside
  services.nginx.virtualHosts.${domain} = {

    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      extraConfig =
        # Recommended settings from https://pve.proxmox.com/wiki/Web_Interface_Via_Nginx_Proxy
        ''
          proxy_buffering       off;
          client_max_body_size  0;
          send_timeout          ${config.services.nginx.proxyTimeout};
        '';
      proxyPass = "https://10.4.10.2:8007/";
      proxyWebsockets = true;
    };
  };
}
