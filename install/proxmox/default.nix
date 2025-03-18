{ config, ... }:

let
  HOST = "server.davidkopczynski.com";
  ADDR = "10.1.0.0";
  PORT = 8006;
in
{
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
        authFile = config.sops.secrets."basic-auth/auth".path;
        tokenFile = config.sops.secrets."basic-auth/token".path;
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

  # Secrets
  sops.secrets."basic-auth/auth" = {
    owner = "nginx";
    group = "nginx";
  };
  sops.secrets."basic-auth/token" = {
    owner = "nginx";
    group = "nginx";
  };
}
