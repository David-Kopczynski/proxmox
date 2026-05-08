{ domain }:
{ config, ... }:

{
  imports = [ ../basic-auth.nix ];

  # Allow access to dashboard with basic auth
  services.nginx.virtualHosts.${domain} = {

    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      extraConfig =
        # Recommended settings from https://pve.proxmox.com/wiki/Web_Interface_Via_Nginx_Proxy
        ''
          proxy_buffering       off;
          client_max_body_size  0;
          send_timeout          ${config.services.nginx.proxyTimeout};
        ''
        + config.nginx.basic_auth {
          authFile = config.sops.secrets."basic-auth/auth".path;
          tokenFile = config.sops.templates."basic-auth/token".path;
        };
      proxyPass = "https://10.4.10.1:8006/";
      proxyWebsockets = true;
    };
  };

  # Secrets
  sops.secrets."basic-auth/auth" = {
    owner = "nginx";
    group = "nginx";
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."basic-auth/token" = {
    owner = "nginx";
    group = "nginx";
    sopsFile = ./secrets.yaml;
  };
  sops.templates."basic-auth/token" = {
    content = ''
      set  $auth_token "${config.sops.placeholder."basic-auth/token"}";
    '';
    owner = "nginx";
    group = "nginx";
  };
}
