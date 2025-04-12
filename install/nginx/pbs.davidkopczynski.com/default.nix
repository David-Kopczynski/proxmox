{ domain }:
{ ... }:

{
  # Allow access to dashboard from outside
  services.nginx.virtualHosts.${domain} = {

    enableACME = true;
    forceSSL = true;
    locations."/" = {
      extraConfig = ''
        access_log off;
      '';
      proxyPass = "https://192.168.0.170:8007/";
      proxyWebsockets = true;
    };
  };
}
