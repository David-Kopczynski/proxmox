{ lib, hasDataDisk, ... }:

{
  imports = [ "${fetchTarball "https://github.com/nix-community/disko/tarball/master"}/module.nix" ];

  disko.devices.disk =
    # Default disk setup using EFI partition
    {
      "system" = {
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            "ESP" = {
              priority = 1;
              size = "126M"; # Align with 1MiB padding at start and end of disk
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            "swap" = {
              priority = 2;
              size = "896M";
              content = {
                type = "swap";
              };
            };
            "root" = {
              priority = 3;
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    }
    //
    # Extra data disk without partitioning (optional)
    lib.optionalAttrs hasDataDisk {
      "data" = {
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1";
        type = "disk";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/data";
        };
      };
    };
}
