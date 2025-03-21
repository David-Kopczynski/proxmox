{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Origin Server Certificates (SSL)
  # Ideally, also enable Full (Strict) SSL on Cloudflare
  options.cloudflare.sslCertificate = with lib; mkOption { type = types.str; };
  config.cloudflare.sslCertificate = toString (
    builtins.toFile "cloudflare-ssl-certificate.pem" ''
      -----BEGIN CERTIFICATE-----
      MIIEsjCCA5qgAwIBAgIUeZvoxQ9UGpImJ5SbmpR53UfuVVgwDQYJKoZIhvcNAQEL
      BQAwgYsxCzAJBgNVBAYTAlVTMRkwFwYDVQQKExBDbG91ZEZsYXJlLCBJbmMuMTQw
      MgYDVQQLEytDbG91ZEZsYXJlIE9yaWdpbiBTU0wgQ2VydGlmaWNhdGUgQXV0aG9y
      aXR5MRYwFAYDVQQHEw1TYW4gRnJhbmNpc2NvMRMwEQYDVQQIEwpDYWxpZm9ybmlh
      MB4XDTI0MTAxMTE5MzcwMFoXDTM5MTAwODE5MzcwMFowYjEZMBcGA1UEChMQQ2xv
      dWRGbGFyZSwgSW5jLjEdMBsGA1UECxMUQ2xvdWRGbGFyZSBPcmlnaW4gQ0ExJjAk
      BgNVBAMTHUNsb3VkRmxhcmUgT3JpZ2luIENlcnRpZmljYXRlMIIBIjANBgkqhkiG
      9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyu/oycjF4o7FBunF8Q8nP9JKhUOwSs9mjc92
      VkMJbmx3Q2aBItyahYQ6Qd3Yz9TwjfXWE2P86NwEPGwl4Vejsoot/3TrqZruL4dw
      n5phqyXM1OOYIq1SYhnMAl062XAU/NFGY1i7Y1rBN3Bi7iHOAKUUXygDvuB/3JRX
      DWYeKx9FtnmuGjGLkGBI0NV6fIQkvgTYQkoOuw+QQrMONWZHpEV+8DcYtNuHIknL
      jc9Zooeo+qj/BjTys0Su39/vveS1eZ3WjvMvlRK4HwAS8+EeYtmDXqqNOs9UGZ4g
      RqLBFSlLGcw0LeNzU9chgF9biRU0/qQz+1bI8UDM/fqz+3z/5wIDAQABo4IBNDCC
      ATAwDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcD
      ATAMBgNVHRMBAf8EAjAAMB0GA1UdDgQWBBQGliHUNq0LCLAtZKukihD0eKnmoTAf
      BgNVHSMEGDAWgBQk6FNXXXw0QIep65TbuuEWePwppDBABggrBgEFBQcBAQQ0MDIw
      MAYIKwYBBQUHMAGGJGh0dHA6Ly9vY3NwLmNsb3VkZmxhcmUuY29tL29yaWdpbl9j
      YTA1BgNVHREELjAsghUqLmRhdmlka29wY3p5bnNraS5jb22CE2Rhdmlka29wY3p5
      bnNraS5jb20wOAYDVR0fBDEwLzAtoCugKYYnaHR0cDovL2NybC5jbG91ZGZsYXJl
      LmNvbS9vcmlnaW5fY2EuY3JsMA0GCSqGSIb3DQEBCwUAA4IBAQAA30vc3JdANuMH
      dO3AlopfDTNan9zv8Z+LeImIfalBVVCEaezHii3M/O9FWV5LWYGY9Jc9I2IDjMCD
      YO8kCXw6WVlJ6VyADkrowTU0g3nkR6mOnAlUPzXVIHoHupogdQtQDPuwVA3flWVG
      riqRYN0MQ0Ax+4kQ5oAhSaUum7thwu9G382C4oUekqu5viN69uug3xlMlQnePDjD
      noj8cO3A40eniE6/KTMj7dm/OPjnWRjZYbRG2V/IB4xMozVETgpL8M6kkR2gdyGr
      kDKLHyorwI9nTLsqxwKCxcmNplsOX1TaZFsiyO3A/2TXxMbZ2qhHCc7eh/O1rzZ0
      g/SGfXe5
      -----END CERTIFICATE-----
    ''
  );

  options.cloudflare.sslCertificateKey = with lib; mkOption { type = types.str; };
  config.cloudflare.sslCertificateKey = config.sops.secrets."certificates/key".path;

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
      include ${builtins.toFile "cloudflare-nginx-configuration" ''
        # Update real IP address from Cloudflare
        ${realIpsFromList cloudflare-ipv4}
        ${realIpsFromList cloudflare-ipv6}
        real_ip_header CF-Connecting-IP;

        # Maximum upload limit
        client_max_body_size 100M;

        # Disable OCSP stapling
        ssl_stapling off;
      ''};
    '';

  # Secrets
  config.sops.secrets."certificates/key" = {
    owner = "nginx";
    group = "nginx";
  };
}
