{ ... }:

let
  HOST = "davidkopczynski.com";
  MAIL = "mail@davidkopczynski.com";
  DATA = /data/nginx;
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

    # Additional custom security headers
    appendHttpConfig = ''
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
      add_header X-Content-Type-Options nosniff;
      add_header X-Frame-Options SAMEORIGIN;
      add_header X-Robots-Tag none;
    '';
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

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
    usev6 = "webv6, webv6=ipv6.ident.me/";
    zone = HOST;
    domains = [ HOST ];
    username = "token";
    passwordFile = toString (DATA + ./cloudflare.token);
    interval = "1min";
  };
}
