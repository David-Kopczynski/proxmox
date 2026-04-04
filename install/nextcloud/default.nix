{ domain }:
{ pkgs, config, ... }:

{
  services.nextcloud.enable = true;
  services.nextcloud = {

    package = pkgs.nextcloud32;

    # General configuration
    hostName = domain;
    home = toString /data;

    autoUpdateApps.enable = true;
    imaginary.enable = true;
    maxUploadSize = "10G";

    settings.default_phone_region = "DE";
    settings."maintenance_window_start" = 3;
    phpOptions."opcache.interned_strings_buffer" = "64";

    settings.trusted_domains = [ config.networking.hostName ];
    settings.trusted_proxies = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ];

    # Mail notifications
    settings.mail_from_address = builtins.head (builtins.match "^([^.]+)\\..+$" domain); # for subdomain
    settings.mail_domain = builtins.head (builtins.match "^[^.]+\\.(.+)$" domain); # for rest
    settings.mail_smtphost = "smtp.ionos.de";
    settings.mail_smtpport = 587;
    settings.mail_smtpauth = true;
    settings.mail_smtpname = "mail@davidkopczynski.com";

    # Secrets
    secretFile = config.sops.templates."secrets".path;

    # Faster database
    config.dbtype = "pgsql";
    database.createLocally = true;

    # Initial admin password that should be changed after first login
    config.adminpassFile = builtins.toFile "initial-admin-password" ''
      NextcloudAdminPassword!
    '';
  };

  # Allow access to service from nginx
  networking.firewall.allowedTCPPorts = [ 80 ];

  # Secrets
  sops.secrets."mail/password" = {
    owner = "nextcloud";
    group = "nextcloud";
  };
  sops.templates."secrets" = {
    content = builtins.toJSON {
      "mail_smtppassword" = config.sops.placeholder."mail/password";
    };
    owner = "nextcloud";
    group = "nextcloud";
  };
}
