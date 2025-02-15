{ ... }:

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
      proxyPass = "https://${ADDR}:${toString PORT}/";
    };
    locations."~ websocket" = {
      proxyPass = "https://${ADDR}:${toString PORT}";
      proxyWebsockets = true;
    };
  };
}
