{ domain }:
{ config, ... }:

{
  services.mealie.enable = true;
  services.mealie = {

    # General configuration
    settings."BASE_URL" = "https://${domain}";

    # Mail notifications
    settings."SMTP_FROM_EMAIL" =
      let
        # Split domain from "sub.domain.code" to [ "sub" "domain.code" ]
        parts = builtins.match "^([^.]+)\\.(.+)$" domain;
      in
      "${builtins.elemAt parts 0}@${builtins.elemAt parts 1}";
    settings."SMTP_HOST" = "smtp.ionos.de";
    settings."SMTP_PORT" = 587;
    settings."SMTP_USER" = "mail@davidkopczynski.com";

    # Secrets
    credentialsFile = config.sops.templates."credentials".path;

    # Database optimization
    database.createLocally = true;
  };

  # Nginx reverse proxy to Mealie with port 9000
  imports = [ ../nginx/proxy-pass.client.nix ];

  services.nginx.enable = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      proxyPass = "http://${config.services.mealie.listenAddress}:${toString config.services.mealie.port}/";
      proxyWebsockets = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  # Secrets
  sops.secrets."mail/password" = { };
  sops.templates."credentials".content = ''
    SMTP_PASSWORD="${config.sops.placeholder."mail/password"}"
  '';
}
