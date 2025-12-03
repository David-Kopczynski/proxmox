{ lib, ... }:

{
  # Allow proxying without overwriting current protocol (modified recommendedProxySettings)
  # This fixes websockets with my `user -> https -> http -> service` setup
  options.nginx.proxyWebsocketsConfig = with lib; mkOption { type = types.str; };
  config.nginx.proxyWebsocketsConfig = ''
    proxy_set_header Host               $host;
    proxy_set_header X-Real-IP          $remote_addr;
    proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Host   $host;
  '';
}
