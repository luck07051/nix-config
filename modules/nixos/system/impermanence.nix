{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.myConfig.system.impermanence;
in
{
  options.myConfig.system.impermanence = {
    enable = mkEnableOption "Impermanence on btrfs";

    device = mkOption {
      type = types.str;
      default = "";
      example = "/dev/sda4";
      description = "TODO: ";
    };

    persist_dir = mkOption {
      type = types.str;
      default = "/persist";
      description = "";
    };
  };

  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  config = mkIf cfg.enable {
    # Filesystem modifications needed for impermanence
    fileSystems.${persist_dir}.neededForBoot = true;

    boot.initrd.postDeviceCommands = pkgs.lib.mkAfter ''
      delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
          delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
      }

      mkdir /btrfs_tmp
      mount ${device} /btrfs_tmp

      mkdir -p /btrfs_tmp/snapshots
      timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@)" "+%Y-%m-%-d_%H:%M:%S")
      mv /btrfs_tmp/@ "/btrfs_tmp/snapshots/$timestamp"

      for i in $(find /btrfs_tmp/snapshots/ -maxdepth 1 -mtime +7); do
        delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/@
      umount /btrfs_tmp
    '';

    users.mutableUsers = false;

    environment.persistence.main = {
      persistentStoragePath = persist_dir;
      hideMounts = true;

      directories = [
        "/var/lib/systemd"
        "/var/lib/nixos"
        "/var/log"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };
}