{ pkgs, ... }:

let
  HOST = "cloud.davidkopczynski.com";
  DATA = /data/nextcloud;
in
{
  services.nextcloud.enable = true;
  services.nextcloud.home = toString (DATA + "/home");
  services.nextcloud.secretFile = toString (DATA + "/secrets.json");
  services.nextcloud.hostName = HOST;
  services.nextcloud = {

    package = pkgs.nextcloud30;

    # General configuration
    autoUpdateApps.enable = true;
    configureRedis = true;
    https = true;
    maxUploadSize = "10G";

    settings = {
      maintenance_window_start = 3;
      default_phone_region = "DE";
    };

    phpOptions = {
      "opcache.interned_strings_buffer" = "64";
    };

    # Faster database
    config.dbtype = "pgsql";
    database.createLocally = true;

    # Initial admin password that should be changed after first login
    config.adminpassFile = builtins.toFile "initial-admin-password" ''
      NextcloudAdminPassword!
    '';
  };

  # Nginx reverse proxy to Nextcloud
  services.nginx.virtualHosts.${HOST} = {

    enableACME = true;
    forceSSL = true;
  };
}
