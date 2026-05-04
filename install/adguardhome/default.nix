{ ... }:
{ config, ... }:

let
  GATE = "10.4.0.1";
in
{
  services.adguardhome.enable = true;
  services.adguardhome = {

    # General configuration
    host = "127.0.0.1";

    # DNS upstreams
    settings.dns.upstream_dns =
      # DNS over HTTPs/QUIC servers for external resolution
      [
        "https://dns.google/dns-query"
        "https://dns.quad9.net/dns-query"
        "https://dns.cloudflare.com/dns-query"
        "quic://dns.adguard-dns.com"
      ]
      # Resolve hostnames and .internal domains with local DNS
      ++ [
        "[//]${GATE}" # resolves hostnames
        "[/internal/]${GATE}" # resolves .internal domains
      ]
      # rDNS for IP hostname resolution
      ++ [
        "[/in-addr.arpa/]${GATE}" # resolves IPv4 reverse lookups
        "[/ip6.arpa/]${GATE}" # resolves IPv6 reverse lookups
      ];
    settings.dns.bootstrap_dns =
      # Cloudflare DNS for initial resolution of upstream DNS servers
      [ "1.1.1.1" ] ++ [ "1.0.0.1" ] ++ [ "2606:4700:4700::1111" ] ++ [ "2606:4700:4700::1001" ];

    # Advanced DNS features
    settings.dns.enable_dnssec = true;
    settings.dns.edns_client_subnet.enabled = true;

    # Performance optimizations
    settings.dns.ratelimit = 0;
    settings.dns.upstream_mode = "load_balance";
    settings.dns.upstream_timeout = "1s";
    settings.dns.fallback_dns = [ GATE ];

    # Resolve local domains with gateway DNS
    settings.clients.runtime_sources.rdns = true;
    settings.dns.use_private_ptr_resolvers = true;
    settings.dns.local_ptr_upstreams = [ GATE ];

    # Prevent invalid hostname resolution from local machine
    settings.clients.runtime_sources.hosts = false;
    settings.dns.hostsfile_enabled = false;
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
