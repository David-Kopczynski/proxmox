{ domain }:
{ ... }:

{
  # Allow access to dashboard from outside
  services.nginx.virtualHosts.${domain} = {

    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://10.0.1.20:8007/";
      proxyWebsockets = true;
    };
  };
}
