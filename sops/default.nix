{ sopsFile }:

{
  imports = [ "${(import ../npins).sops-nix}/modules/sops" ];

  sops.defaultSopsFile = sopsFile;
  sops.defaultSopsFormat = "yaml";

  sops.age.sshKeyFile = "/etc/ssh/ssh_host_ed25519_key";

  sops.age.sshKeyPaths = [ ];
  sops.gnupg.sshKeyPaths = [ ];
}
