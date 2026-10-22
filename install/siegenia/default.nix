{ domain }:
{ config, ... }:

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
  };

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
