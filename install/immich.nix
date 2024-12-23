{ ... }:

let
  DATA = /data/immich;
in
{
  services.immich.enable = true;
  services.immich.mediaLocation = toString DATA;
  services.immich.secretsFile = toString (DATA + ./secrets.env);

  # Enable hardware acceleration
  users.users.immich.extraGroups = [
    "video"
    "render"
  ];
}
