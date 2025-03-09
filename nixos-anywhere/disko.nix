{ ... }:

{
  imports = [ "${fetchTarball "https://github.com/nix-community/disko/tarball/master"}/module.nix" ];

  # Default disk setup using EFI partition
  disko.devices.disk."system" = {

    device = "/dev/sda";
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

  # Extra data disk without partitioning
  disko.devices.disk."data" = {

    device = "/dev/sdb";
    type = "disk";
    content = {
      type = "filesystem";
      format = "ext4";
      mountpoint = "/data";
    };
  };
}
