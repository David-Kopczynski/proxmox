{
  config,
  domain,
  pkgs,
  ...
}:

{
  services.nextcloud.enable = true;
  services.nextcloud.home = toString /data;
  services.nextcloud = {

    package = pkgs.nextcloud30;

    # General configuration
    hostName = domain;

    autoUpdateApps.enable = true;
    configureRedis = true;
    maxUploadSize = "10G";

    settings = {
      maintenance_window_start = 3;
      default_phone_region = "DE";

      trusted_domains = [ config.networking.hostName ];
      trusted_proxies = [ "192.168.0.0/24" ];
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
