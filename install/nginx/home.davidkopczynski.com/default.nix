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
        # Recommended settings from https://community.home-assistant.io/t/reverse-proxy-using-nginx/196954
        ''
          proxy_buffering  off;
          send_timeout     ${config.services.nginx.proxyTimeout};
        '';
      proxyPass = "http://10.5.4.106:8123/";
      proxyWebsockets = true;
    };
  };
}
