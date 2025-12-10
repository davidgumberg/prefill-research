# Copied and pasted from the disko readme: https://github.com/nix-community/disko/blob/d64e5cdca35b5fad7c504f615357a7afe6d9c49e/README.md#sample-configuration-and-cli-command
{
  disko.devices = {
    disk = {
      my-disk = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
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
    };
  };
}
