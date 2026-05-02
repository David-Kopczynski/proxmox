{ domain }:
{ config, ... }:

{
  services.immich.enable = true;
  services.immich = {

    # General configuration
    host = "127.0.0.1";
    settings.server.externalDomain = "https://${domain}";

    mediaLocation = toString /data;
    secretsFile = config.sops.templates."environment".path;

    # Mail notifications
    settings.notifications.smtp.enabled = true;
    settings.notifications.smtp = {

      from =
        let
          # Split domain from "sub.domain.code" to [ "sub" "domain.code" ]
          parts = builtins.match "^([^.]+)\\.(.+)$" domain;
        in
        "Immich <${builtins.elemAt parts 0}@${builtins.elemAt parts 1}>";
      transport.host = "smtp.ionos.de";
      transport.port = 587;
      transport.username = "mail@davidkopczynski.com";
      transport.password._secret = config.sops.secrets."mail/password".path;
    };

    # Allow all hardware acceleration devices
    accelerationDevices = null;
  };

  # Enable hardware acceleration
  users.users.immich.extraGroups = [ "video" ] ++ [ "render" ];

  # Nginx reverse proxy to Immich with port 2283
  imports = [ ../nginx/proxy-pass.client.nix ];

  services.nginx.enable = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      extraConfig = ''
        client_max_body_size  0;
      '';
      proxyPass = "http://${config.services.immich.host}:${toString config.services.immich.port}/";
      proxyWebsockets = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  # Secrets
  sops.secrets."db/password" = {
    owner = "immich";
    group = "immich";
  };
  sops.secrets."mail/password" = {
    owner = "immich";
    group = "immich";
  };
  sops.templates."environment" = {
    content = ''
      DB_PASSWORD="${config.sops.placeholder."db/password"}"
    '';
    owner = "immich";
    group = "immich";
  };
}
