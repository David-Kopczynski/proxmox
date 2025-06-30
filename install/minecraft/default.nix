{ ... }:
{ ... }:

{
  # Newest Minecraft server version
  nixpkgs.overlays = [
    (final: prev: {
      minecraft-server = prev.minecraft-server.override {
        version = "1.21.7";
        url = "https://piston-data.mojang.com/v1/objects/05e4b48fbc01f0385adb74bcff9751d34552486c/server.jar";
        sha1 = "sha1-BeS0j7wB8Dha23S8/5dR00VSSGw=";
      };
    })
  ];

  services.minecraft-server.enable = true;
  services.minecraft-server = {

    # General configuration
    declarative = true;
    eula = true;
    openFirewall = true;

    # Allowed players
    whitelist."StableThulium" = "73dd60b2-7616-4ccf-92b4-70898a6ac80e";

    # Game configuration and tweaks
    jvmOpts = "-Xms4092M -Xmx4092M -XX:+UseG1GC";

    serverProperties.difficulty = 2;
    serverProperties.enforce-whitelist = true;
    serverProperties.motd = "CHICKEN JOCKEY!";
    serverProperties.white-list = true;
  };
}
