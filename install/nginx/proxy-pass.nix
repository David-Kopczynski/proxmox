{
  cloudflare ? false,
  default ? false,
  domain,
  targetHost,
}:
{ config, ... }:

{
  imports = [ ./cloudflare.nix ];

  services.nginx.virtualHosts.${domain} = {

    # Configure if domain is default server
    inherit default;

    # Basic configuration for all services
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://${targetHost}/";
      proxyWebsockets = true;

      extraConfig =
        # Disable all limits and buffering features
        # These should be set in the second Nginx instance
        + ''
          client_max_body_size     0;

          proxy_buffering          off;
          proxy_request_buffering  off;
        '';
    };

    # Configuration if Tunneling is disabled (DNS only)
    # Manage certificates manually
    enableACME = !cloudflare;
    extraConfig = if cloudflare then config.cloudflare.extraConfig else "";

    # Configuration if Tunneling is enabled (Cloudflare)
    sslCertificate = if cloudflare then config.cloudflare.sslCertificate else null;
    sslCertificateKey = if cloudflare then config.cloudflare.sslCertificateKey else null;
  };
}
