{ config, ... }:

let
  HOST = "patch.davidkopczynski.com";
  MOVE = "https://www.rwth-aachen.de/global/show_document.asp?id=aaaaaaaaaaajyav";
in
{
  # Redirect patch. to page of my choice
  services.nginx.virtualHosts.${HOST} = {

    inherit (config.cloudflare)
      extraConfig
      sslCertificate
      sslCertificateKey
      ;
    forceSSL = true;
    locations."/" = {
      return = "302 ${MOVE}";
    };
  };
}
