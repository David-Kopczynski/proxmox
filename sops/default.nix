{ sopsFile, ... }:

{
  imports = [ <sops-nix/modules/sops> ];

  sops.defaultSopsFile = sopsFile;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = toString /home/${"user"}/.config/sops/age/keys.txt;
}
