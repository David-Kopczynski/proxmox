{ domain }:
{ config, ... }:

{
  imports = [ ../cloudflare.nix ];

  # Allow access to dashboard from outside
  services.nginx.virtualHosts.${domain} = {

    inherit (config.cloudflare)
      extraConfig
      sslCertificate
      sslCertificateKey
      ;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://192.168.0.48:8123/";
      proxyWebsockets = true;
    };
  };
}
