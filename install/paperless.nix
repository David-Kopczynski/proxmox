{ config, ... }:

let
  HOST = "archive.davidkopczynski.com";
  DATA = /data/paperless;
in
{
  services.paperless.enable = true;
  services.paperless.dataDir = toString DATA;
  services.paperless.address = HOST;
  services.paperless.settings = {

    # Custom settings for my optimal setup
    PAPERLESS_OCR_LANGUAGE = "deu+eng";
    PAPERLESS_OCR_USER_ARGS = {

      # This prevents failure when PDF is signed
      invalidate_digital_signatures = true;
    };
  };

  # Nginx reverse proxy to Paperless with port 28981
  services.nginx.virtualHosts.${HOST} = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.paperless.port}";
      proxyWebsockets = true;
    };
  };
}
