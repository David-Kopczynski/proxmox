{ config, lib, ... }:

let
  HOST = "archive.davidkopczynski.com";
  DATA = /data/paperless;
in
{
  services.paperless.enable = true;
  services.paperless.dataDir = toString DATA;
  services.paperless.settings = {

    # Custom settings for my optimal setup
    PAPERLESS_OCR_LANGUAGE = "deu+eng";
    PAPERLESS_OCR_USER_ARGS = {

      # PDF optimization
      optimize = 1;
      pdfa_image_compression = "lossless";

      # This prevents failure when PDF is signed
      invalidate_digital_signatures = true;
    };

    # Add office document support
    PAPERLESS_TIKA_ENABLED = true;
    PAPERLESS_TIKA_ENDPOINT = "http://${config.services.tika.listenAddress}:${toString config.services.tika.port}";
    PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://127.0.0.1:${toString config.services.gotenberg.port}";
  };

  # Required services for office document support
  services.tika.enable = true;
  services.tika.listenAddress = "127.0.0.1";

  services.gotenberg.enable = true;
  services.gotenberg.chromium.disableJavascript = true;

  # Fix gotenberg environment issues
  # see https://github.com/NixOS/nixpkgs/issues/349123
  systemd.services."gotenberg".environment = {
    HOME = "/run/gotenberg";
  };
  systemd.services."gotenberg".serviceConfig = {
    SystemCallFilter = lib.mkAfter [ "@chown" ];
    WorkingDirectory = "/run/gotenberg";
    RuntimeDirectory = "gotenberg";
  };

  # Nginx reverse proxy to Paperless with port 28981
  services.nginx.virtualHosts.${HOST} = {

    inherit (config.cloudflare)
      extraConfig
      sslCertificate
      sslCertificateKey
      ;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.paperless.port}";
    };
    locations."/ws/" = {
      inherit (config.services.nginx.virtualHosts.${HOST}.locations."/")
        proxyPass
        ;
      proxyWebsockets = true;
    };
  };
}
