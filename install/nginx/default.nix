{ ... }:
{ config, ... }:

let
  HOST = "davidkopczynski.com";
  MAIL = "mail@davidkopczynski.com";
  ETH0 = "ens18";
in
{
  services.nginx.enable = true;
  services.nginx = {

    # Use recommended settings
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;

    # General configuration
    appendConfig = ''
      worker_processes auto;
    '';

    # Additional custom security headers
    appendHttpConfig = ''
      proxy_hide_header Referrer-Policy;
      proxy_hide_header Strict-Transport-Security;
      proxy_hide_header X-Content-Type-Options;
      proxy_hide_header X-Frame-Options;
      proxy_hide_header X-Permitted-Cross-Domain-Policies;
      proxy_hide_header X-Robots-Tag;
      proxy_hide_header X-XSS-Protection;

      add_header Referrer-Policy "strict-origin-when-cross-origin" always;
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
      add_header X-Content-Type-Options nosniff;
      add_header X-Frame-Options SAMEORIGIN;
      add_header X-Permitted-Cross-Domain-Policies none;
      add_header X-Robots-Tag noindex,nofollow;
      add_header X-XSS-Protection "1; mode=block";
    '';
  };

  networking.firewall.allowedTCPPorts = [ 80 ] ++ [ 443 ];

  # Enable ACME for automatic SSL certificates
  # A separate certificate will be generated for all domains with enableACME
  security.acme = {
    acceptTerms = true;
    defaults.email = MAIL;
  };

  # Automatically propagate IP address changes to DNS
  services.ddclient.enable = true;
  services.ddclient = {

    protocol = "cloudflare";
    usev4 = "webv4, webv4=ipv4.ident.me/";
    zone = HOST;
    domains = [ HOST ];
    username = "token";
    passwordFile = config.sops.secrets."cloudflare/token".path;
    interval = "1min";
  };

  # Prevent incorrect IPv6 address resolution
  networking.interfaces.${ETH0}.tempAddress = "disabled";

  # Secure SSH/Nginx with Fail2Ban
  services.fail2ban.enable = true;
  services.fail2ban.bantime-increment.enable = true;

  services.fail2ban.jails = {
    "nginx-bad-request".settings = {
      enabled = true;
      backend = "auto";
      logpath = "/var/log/nginx/access.log";
    };
    "nginx-botsearch".settings = {
      enabled = true;
      backend = "auto";
      logpath = "/var/log/nginx/access.log";
    };
    "nginx-forbidden".settings = {
      enabled = true;
    };
    "nginx-http-auth".settings = {
      enabled = true;
    };
  };

  # Secrets
  sops.secrets."cloudflare/token" = {
    owner = "nginx";
    group = "nginx";
  };
}
