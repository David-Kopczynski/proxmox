{ ... }:
{ config, ... }:

{
  services.adguardhome.enable = true;
  services.adguardhome = {

    # General configuration
    host = "127.0.0.1";
  };

  # Nginx reverse proxy to AdGuard-Home with port 3000
  imports = [ ../nginx/proxy-pass.client.nix ] ++ [ ../nginx/basic-auth.nix ];

  services.nginx.enable = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      extraConfig = config.nginx.basic_auth {
        authFile = config.sops.secrets."basic-auth/auth".path;
        tokenFile = config.sops.templates."basic-auth/token".path;
      };
      proxyPass = "http://${config.services.adguardhome.host}:${toString config.services.adguardhome.port}/";
    };
  };

  networking.firewall.allowedTCPPorts = [ 53 ] ++ [ 853 ] ++ [ 80 ];
  networking.firewall.allowedUDPPorts = [ 53 ] ++ [ 853 ];

  # Secrets
  sops.secrets."basic-auth/auth" = {
    owner = "nginx";
    group = "nginx";
  };
  sops.secrets."basic-auth/token" = {
    owner = "nginx";
    group = "nginx";
  };
  sops.templates."basic-auth/token" = {
    content = ''
      set  $auth_token "${config.sops.placeholder."basic-auth/token"}";
    '';
    owner = "nginx";
    group = "nginx";
  };
}
