{ config, modulesPath, ... }:

let
  HOST = "server.davidkopczynski.com";
  ADDR = "10.1.0.0";
  PORT = 8006;
  DATA = /data/proxmox;
in
{
  # Hardware specific configuration
  # These values are taken from the initial hardware-configuration.nix
  nixpkgs.hostPlatform = "x86_64-linux";

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Enable bootloader from initial configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Grow the root partition to fill the disk
  boot.growPartition = true;

  # Add filesystem partitions
  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    autoResize = true;
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "ext4";
    autoResize = true;
  };

  fileSystems."/data/nextcloud" = {
    device = "/dev/disk/by-label/nextcloud";
    fsType = "ext4";
    autoResize = true;
  };

  fileSystems."/data/immich" = {
    device = "/dev/disk/by-label/immich";
    fsType = "ext4";
    autoResize = true;
  };

  # Automatically keep system clean
  boot.loader.systemd-boot.configurationLimit = 8;
  nix.gc.automatic = true;
  nix.optimise.automatic = true;

  # Configure QEMU quest agent for safe shutdown
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  services.qemuGuest.enable = true;

  # Enable networking
  networking.hostName = "nixos-server";
  networking.networkmanager.enable = true;

  # Enable SSH
  programs.ssh.startAgent = true;
  services.openssh.enable = true;

  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.KbdInteractiveAuthentication = false;
  users.users."root".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILPLqP71iBRAFd7OFIjlkN6yGEr++G5eRDJ+U57R9f8e user@nixos"
  ];

  # Update locale and timezone
  console.keyMap = "de";
  time.timeZone = "Europe/Berlin";

  # Allow access to dashboard from local network
  services.nginx.virtualHosts.${HOST} = {

    inherit (config.cloudflare)
      extraConfig
      sslCertificate
      sslCertificateKey
      sslTrustedCertificate
      ;
    forceSSL = true;
    locations."/" = {
      basicAuthFile = toString (DATA + "/connect.auth");
      proxyPass = "https://${ADDR}:${toString PORT}/";
      proxyWebsockets = true;
    };
  };

  # Install version
  system.stateVersion = "24.11";
}
