{ ... }:
{ pkgs, ... }:

{
  services.minecraft-server.enable = true;
  services.minecraft-server = {

    # General configuration
    declarative = true;
    eula = true;
    openFirewall = true;

    # Version
    package = with pkgs; papermcServers.papermc-1_21_8;

    # Allowed players
    whitelist."Mathisphonix" = "9cfa09b4-b042-4b15-8b96-2552d44439e1";
    whitelist."Ra_Orkon" = "63383045-811e-4827-ac76-e1437cdf58c5";
    whitelist."StableThulium" = "73dd60b2-7616-4ccf-92b4-70898a6ac80e";
    whitelist."StefaniusMaximus" = "7436b20a-c89d-45e7-a740-b5604f4ae66d";
    whitelist."Terminal79" = "8e4f7d49-5b4d-4f80-af46-59ff53e0e821";
    whitelist."TheChaosBrain" = "cde2ebf7-3c01-4420-ac34-29f05f5c1656";
    whitelist."_Minas_" = "bcbf481f-739d-41f8-8623-32c9622b7e30";

    # Game configuration and tweaks
    jvmOpts = "-Xms4092M -Xmx4092M -XX:+UseG1GC";

    serverProperties.difficulty = 2;
    serverProperties.enforce-whitelist = true;
    serverProperties.motd = "CHICKEN JOCKEY!";
    serverProperties.view-distance = 16;
    serverProperties.white-list = true;
  };
}
