{ domain }:
{ config, ... }:

{
  imports = [ ../cloudflare.nix ];

  # Redirect patch to page of my choice
  services.nginx.virtualHosts.${domain} = {

    inherit (config.cloudflare)
      extraConfig
      sslCertificate
      sslCertificateKey
      ;
    forceSSL = true;
    locations."/" = {
      return = "302 https://www.rwth-aachen.de/global/show_document.asp?id=aaaaaaaaaaajyav";
    };
  };
}
