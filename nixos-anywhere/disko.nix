{ lib, hasDataDisk, ... }:

{
  imports = [ "${fetchTarball "https://github.com/nix-community/disko/tarball/master"}/module.nix" ];

  disko.devices.disk =
    # Default disk setup using EFI partition
    {
      "system" = {
        device = "/dev/disk/by-path/pci-0000:01:01.0-scsi-0:0:0:0";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            "ESP" = {
              priority = 1;
              size = "125M";
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
              size = "875M";
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
        device = "/dev/disk/by-path/pci-0000:01:02.0-scsi-0:0:0:1";
        type = "disk";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/data";
        };
      };
    };
}
