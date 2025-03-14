{ config, modulesPath, ... }:

let
  HOST = "server.davidkopczynski.com";
  ADDR = "10.1.0.0";
  PORT = 8006;
  DATA = /data/proxmox;
in
{
  system.name = "server";
  nixpkgs.hostPlatform = "x86_64-linux";

  # (Tweaked) boot parameters taken from hardware-configuration.nix
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
  ];

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
    options = [ "umask=0077" ];
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
  nix.gc.options = "--delete-older-than 14d";
  nix.optimise.automatic = true;

  # Configure QEMU quest agent for safe shutdown
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  services.qemuGuest.enable = true;

  systemd.extraConfig = "DefaultTimeoutStopSec=10s";

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

  services.fail2ban.enable = true;
  services.fail2ban.bantime-increment.enable = true;

  # Update locale and timezone
  console.keyMap = "de";
  time.timeZone = "Europe/Berlin";

  # Allow access to dashboard from local network
  services.nginx.virtualHosts.${HOST} = {

    inherit (config.cloudflare)
      extraConfig
      sslCertificate
      sslCertificateKey
      ;
    forceSSL = true;
    locations."/" = {
      extraConfig = config.nginx.basic_auth {
        authFile = DATA + "/connect.auth";
        tokenFile = DATA + "/connect.token";
      };
      proxyPass = "https://${ADDR}:${toString PORT}/";
    };
    locations."/api2/json/" = {
      inherit (config.services.nginx.virtualHosts.${HOST}.locations."/")
        extraConfig
        ;
      proxyPass = "https://${ADDR}:${toString PORT}/api2/json/";
      proxyWebsockets = true;
    };
  };

  # Optimizations
  services.preload.enable = true;

  documentation.enable = false;

  # Install version
  system.stateVersion = "24.11";
}
