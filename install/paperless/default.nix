{ domain }:
{ config, ... }:

{
  services.paperless.enable = true;
  services.paperless = {

    # General configuration
    settings."PAPERLESS_URL" = "https://${domain}";

    # Custom settings for my optimal setup
    settings."PAPERLESS_OCR_LANGUAGE" = "deu+eng";
    settings."PAPERLESS_OCR_USER_ARGS" = {

      # PDF optimization
      "optimize" = 1;
      "pdfa_image_compression" = "lossless";

      # This prevents failure when PDF is signed
      "invalidate_digital_signatures" = true;
    };

    # Mail notifications
    settings."PAPERLESS_EMAIL_FROM" =
      let
        # Split domain from "sub.domain.code" to [ "sub" "domain.code" ]
        parts = builtins.match "^([^.]+)\\.(.+)$" domain;
      in
      "${builtins.elemAt parts 0}@${builtins.elemAt parts 1}";
    settings."PAPERLESS_EMAIL_HOST" = "smtp.ionos.de";
    settings."PAPERLESS_EMAIL_PORT" = 587;
    settings."PAPERLESS_EMAIL_USE_TLS" = true;
    settings."PAPERLESS_EMAIL_HOST_USER" = "mail@davidkopczynski.com";

    # Secrets
    environmentFile = config.sops.templates."secrets".path;

    # Add office document support
    configureTika = true;

    # Faster database
    database.createLocally = true;
  };

  # Nginx reverse proxy to Paperless with port 28981
  imports = [ ../nginx/proxy-pass.client.nix ];

  services.nginx.enable = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      extraConfig = ''
        client_max_body_size  1G;
      '';
      proxyPass = "http://${config.services.paperless.address}:${toString config.services.paperless.port}/";
      proxyWebsockets = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  # Secrets
  sops.secrets."mail/password" = {
    owner = "paperless";
    group = "paperless";
  };
  sops.templates."secrets" = {
    content = ''
      PAPERLESS_EMAIL_HOST_PASSWORD="${config.sops.placeholder."mail/password"}"
    '';
    owner = "paperless";
    group = "paperless";
  };
}
