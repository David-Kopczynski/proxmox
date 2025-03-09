{ config, ... }:

let
  HOST = "server.davidkopczynski.com";
  ADDR = "10.1.0.0";
  PORT = 8006;
  DATA = /data/proxmox;
in
{
  system.name = "server";

  # Enable networking
  networking.hostName = "nixos-server";

  # Allow access to dashboard from local network
  services.nginx.virtualHosts.${HOST} = {

    inherit (config.cloudflare)
      extraConfig
      sslCertificate
      sslCertificateKey
      ;
    forceSSL = true;
    locations."/" = {
      extraConfig = config.nginx.basic_auth {
        authFile = DATA + "/connect.auth";
        tokenFile = DATA + "/connect.token";
      };
      proxyPass = "https://${ADDR}:${toString PORT}";
    };
    locations."/api2/json/" = {
      inherit (config.services.nginx.virtualHosts.${HOST}.locations."/")
        extraConfig
        proxyPass
        ;
      proxyWebsockets = true;
    };
  };

  # Install version
  system.stateVersion = "24.11";
}
