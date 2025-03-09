{ config, ... }:

let
  HOST = "pbs.davidkopczynski.com";
  ADDR = "10.0.1.20";
  PORT = 8007;
in
{
  # Allow access to dashboard from outside
  services.nginx.virtualHosts.${HOST} = {

    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://${ADDR}:${toString PORT}";
    };
    locations."/api2/json/" = {
      inherit (config.services.nginx.virtualHosts.${HOST}.locations."/")
        proxyPass
        ;
      proxyWebsockets = true;
    };
  };
}
