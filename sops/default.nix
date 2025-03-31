{ sopsFile }:
{ ... }:

{
  imports = [ <sops-nix/modules/sops> ];

  sops.defaultSopsFile = sopsFile;
  sops.defaultSopsFormat = "yaml";

  sops.age.generateKey = true;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
}
