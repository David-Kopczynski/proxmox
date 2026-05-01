{ domain }:
{ ... }:

{
  # Allow access to dashboard from outside
  services.nginx.virtualHosts.${domain} = {

    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://10.4.10.2:8007/";
      proxyWebsockets = true;
    };
  };
}
