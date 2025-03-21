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
    locations."/".proxyPass = "http://${targetHost}";

    # Configuration if Tunneling is disabled (DNS only)
    # Manage certificates manually
    enableACME = !cloudflare;

    # Configuration if Tunneling is enabled (Cloudflare)
    extraConfig = if cloudflare then config.cloudflare.extraConfig else "";
    sslCertificate = if cloudflare then config.cloudflare.sslCertificate else null;
    sslCertificateKey = if cloudflare then config.cloudflare.sslCertificateKey else null;
  };
}
