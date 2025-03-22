{ domain }:
{ ... }:

{
  # Allow access to dashboard from outside
  services.nginx.virtualHosts.${domain} = {

    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://192.168.0.170:8007/";
      proxyWebsockets = true;
    };
  };
}
