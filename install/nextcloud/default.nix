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

    settings = {
      maintenance_window_start = 3;
      default_phone_region = "DE";

      trusted_domains = [ config.networking.hostName ];
      trusted_proxies = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
      ];
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

  # Allow access to service from nginx
  networking.firewall.allowedTCPPorts = [ 80 ];
}
