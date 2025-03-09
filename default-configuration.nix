{ modulesPath, ... }:

{
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
  swapDevices = [ { device = "/dev/disk/by-partlabel/disk-system-swap"; } ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/disk-system-ESP";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/disk-system-root";
    fsType = "ext4";
    autoResize = true;
  };

  fileSystems."/data" = {
    device = "/dev/sdb";
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

  # Optimizations
  services.preload.enable = true;

  documentation.enable = false;
}
