{ domain }:
{ config, ... }:

{
  imports = [ ../cloudflare.nix ] ++ [ ../basic-auth.nix ];

  # Allow access to dashboard with basic auth
  services.nginx.virtualHosts.${domain} = {

    inherit (config.cloudflare)
      extraConfig
      sslCertificate
      sslCertificateKey
      ;
    forceSSL = true;
    locations."/" = {
      extraConfig = config.nginx.basic_auth {
        authFile = config.sops.secrets."basic-auth/auth".path;
        tokenFile = config.sops.templates."basic-auth/token".path;
      };
      proxyPass = "https://192.168.0.169:8006/";
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
      set $auth_token "${config.sops.placeholder."basic-auth/token"}";
    '';
    owner = "nginx";
    group = "nginx";
  };
}
