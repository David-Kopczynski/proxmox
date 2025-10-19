{ domain }:
{ config, ... }:

{
  services.paperless.enable = true;
  services.paperless = {

    # General configuration
    settings.PAPERLESS_URL = "https://${domain}";
    settings.PAPERLESS_TRUSTED_PROXIES = "127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16";

    # Custom settings for my optimal setup
    settings.PAPERLESS_OCR_LANGUAGE = "deu+eng";
    settings.PAPERLESS_OCR_USER_ARGS = {

      # PDF optimization
      optimize = 1;
      pdfa_image_compression = "lossless";

      # This prevents failure when PDF is signed
      invalidate_digital_signatures = true;
    };

    # Add office document support
    configureTika = true;

    # Faster database
    database.createLocally = true;
  };

  # Nginx reverse proxy to Paperless with port 28981
  imports = [ ../nginx/proxy-pass.websockets.nix ];

  services.nginx.enable = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      extraConfig = ''
        ${config.nginx.proxyWebsocketsConfig}

        client_max_body_size 1G;
      '';
      proxyPass = "http://${config.services.paperless.address}:${toString config.services.paperless.port}/";
      proxyWebsockets = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
