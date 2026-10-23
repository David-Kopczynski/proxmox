{ domain }:
{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.minecraft-server.enable = true;
  services.minecraft-server = {

    # General configuration
    declarative = true;
    eula = true;
    openFirewall = true;

    # Version
    package = (import (import ../../npins).nixos-unstable { }).papermcServers.papermc-26_3;

    # Game configuration and tweaks
    jvmOpts = "-Xms4092M -Xmx4092M -XX:+UseG1GC";

    serverProperties.difficulty = 3;
    serverProperties.motd = "Test Minecraft Server";
    serverProperties.view-distance = 16;
    serverProperties.white-list = false;
    serverProperties.enforce-secure-profile = false;
  };

  # Geyser libcrypto.so.3 patch
  systemd.services."minecraft-server".environment."LD_LIBRARY_PATH" = lib.makeLibraryPath (
    with pkgs; [ openssl ]
  );

  # Geyser NetherNet support
  systemd.services."minecraft-server".serviceConfig."RestrictAddressFamilies" = [ "AF_NETLINK" ];

  # Nginx reverse proxy to BlueMap with port 8100
  imports = [ ../nginx/proxy-pass.client.nix ];

  services.nginx.enable = true;
  services.nginx = {

    # General configuration
    recommendedOptimisation = true;
    recommendedProxySettings = true;
  };
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      proxyPass = "http://127.0.0.1:8100";
    };
  };

  networking.firewall.allowedTCPPorts = [ 19132 ] ++ [ 80 ];
  networking.firewall.allowedUDPPorts = [ 19132 ];

  # Automatically propagate IP address changes to DNS
  services.ddclient.enable = true;
  services.ddclient = {

    protocol = "cloudflare";
    zone = domain;
    domains = [ domain ];
    username = "token";
    passwordFile = config.sops.secrets."cloudflare/token".path;
    interval = "1min";
  };

  # Prevent incorrect IPv6 address resolution
  networking.tempAddresses = "disabled";

  # User
  users.users."ddclient".isSystemUser = true;
  users.users."ddclient" = {

    group = "ddclient";
  };
  users.groups."ddclient" = { };

  # Secrets
  sops.secrets."cloudflare/token" = {
    owner = config.users.users."ddclient".name;
    group = config.users.users."ddclient".group;
  };
}
