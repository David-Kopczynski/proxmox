{ lib, pkgs, ... }:

let
  DATA = /data/cloudflare;
in
{
  # Origin Server Certificates (SSL)
  # Ideally, also enable Full (Strict) SSL on Cloudflare
  options.cloudflare.sslCertificate = with lib; mkOption { type = types.str; };
  config.cloudflare.sslCertificate = toString (DATA + "/origin.pem");

  options.cloudflare.sslCertificateKey = with lib; mkOption { type = types.str; };
  config.cloudflare.sslCertificateKey = toString (DATA + "/origin.key");

  # Cloudflare configuration for reverse proxy
  # This is taken from https://nixos.wiki/wiki/Nginx
  options.cloudflare.extraConfig = with lib; mkOption { type = types.str; };
  config.cloudflare.extraConfig =
    let
      realIpsFromList = lib.strings.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");
      fileToList = x: lib.strings.splitString "\n" (builtins.readFile x);
      cloudflare-ipv4 = fileToList (
        pkgs.fetchurl {
          url = "https://www.cloudflare.com/ips-v4";
          sha256 = "0ywy9sg7spafi3gm9q5wb59lbiq0swvf0q3iazl0maq1pj1nsb7h";
        }
      );
      cloudflare-ipv6 = fileToList (
        pkgs.fetchurl {
          url = "https://www.cloudflare.com/ips-v6";
          sha256 = "1ad09hijignj6zlqvdjxv7rjj8567z357zfavv201b9vx3ikk7cy";
        }
      );
    in
    ''
      # Update real IP address from Cloudflare
      ${realIpsFromList cloudflare-ipv4}
      ${realIpsFromList cloudflare-ipv6}
      real_ip_header CF-Connecting-IP;

      # Maximum upload limit
      client_max_body_size 100M;

      # Disable OCSP stapling
      ssl_stapling off;
    '';
}
