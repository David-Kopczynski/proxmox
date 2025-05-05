{ domain }:
{ config, ... }:

{
  services.paperless.enable = true;
  services.paperless.settings = {

    # General configuration
    PAPERLESS_URL = "https://${domain}";
    PAPERLESS_TRUSTED_PROXIES = "127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16";

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

  # Nginx reverse proxy to Paperless with port 28981
  imports = [ ../nginx/proxy-pass.websockets.nix ];

  services.nginx.enable = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      extraConfig = ''
        ${config.nginx.proxyWebsocketsConfig}

        client_max_body_size 100M;
      '';
      proxyPass = "http://127.0.0.1:${toString config.services.paperless.port}/";
      proxyWebsockets = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
