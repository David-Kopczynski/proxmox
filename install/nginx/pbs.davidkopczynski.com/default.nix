{ domain }:
{ config, ... }:

{
  # Allow access to dashboard from outside
  services.nginx.virtualHosts.${domain} = {

    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://10.0.1.20:8007";
    };
    locations."/api2/json/" = {
      inherit (config.services.nginx.virtualHosts.${domain}.locations."/")
        proxyPass
        ;
      proxyWebsockets = true;
    };
  };
}
