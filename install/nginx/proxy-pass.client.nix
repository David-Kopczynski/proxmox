{ config, lib, ... }:

{
  config.services.nginx = {

    # Prevent breaking proxy changes with recommended settings
    recommendedProxySettings = lib.mkForce false;

    appendHttpConfig =
      # Retrieve real client IP from known private ranges
      ''
        set_real_ip_from  127.0.0.0/8;
        set_real_ip_from  10.0.0.0/8;
        set_real_ip_from  172.16.0.0/12;
        set_real_ip_from  192.168.0.0/16;
      ''
      # Also include config for proxying
      + ''
        ${config.nginx.customProxySettings}
      '';
  };

  # Allow proxying without overwriting current protocol (modified recommendedProxySettings)
  # This fixes my `user -> https -> http -> service` setup for certain websockets
  options.nginx.customProxySettings = with lib; mkOption { type = types.str; };
  config.nginx.customProxySettings = ''
    proxy_set_header  Host $host;
    proxy_set_header  X-Real-IP $remote_addr;
    proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header  X-Forwarded-Host $host;
    proxy_set_header  X-Forwarded-Server $hostname;
  '';
}
