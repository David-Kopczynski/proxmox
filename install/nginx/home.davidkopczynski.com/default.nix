{ domain }:
{ ... }:

{
  # Allow access to dashboard from outside
  services.nginx.virtualHosts.${domain} = {

    enableACME = true;
    forceSSL = true;
    locations."/" = {
      extraConfig = ''
        proxy_buffering off;
        proxy_read_timeout 3600s;
      '';
      proxyPass = "http://homeassistant:8123/";
      proxyWebsockets = true;
    };
  };
}
