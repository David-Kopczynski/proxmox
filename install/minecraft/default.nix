{ ... }:
{ config, ... }:

let
  unstable = import <nixos-unstable> { config = config.nixpkgs.config; }; # Temporary solution for newest updates :)
in
{
  services.minecraft-server.enable = true;
  services.minecraft-server = {

    # General configuration
    declarative = true;
    eula = true;
    openFirewall = true;

    # Allowed players
    whitelist."StableThulium" = "73dd60b2-7616-4ccf-92b4-70898a6ac80e";

    # Game configuration and tweaks
    package = unstable.minecraft-server;
    jvmOpts = "-Xms4092M -Xmx4092M -XX:+UseG1GC";

    serverProperties.difficulty = 2;
    serverProperties.enforce-whitelist = true;
    serverProperties.motd = "CHICKEN JOCKEY!";
    serverProperties.white-list = true;
  };
}
