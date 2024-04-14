{ config, lib, pkgs, inputs, outputs, ... }:

# sudo -i
# flake_url='github:luck07051/nix-config#vm-imper-test'
# nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko -f "$flake_url"
# nixos-install --flake "$flake_url" --no-root-passwd

# mkdir -p /mnt/persist/home/ui
# mkdir /mnt/persist/passwords && mkpasswd "pw" > "/mnt/persist/passwords/ui"
# chown ui:users /mnt/persist/home/ui
# chown ui:users /mnt/persist/passwords/ui


{
  imports = [
    ./hardware-configuration.nix
    (import ./disko-config.nix { device = "/dev/vda"; })
  ];

  system.stateVersion = "23.11";

  networking.hostName = "vm-imper-test";
  time.timeZone = "Asia/Taipei";

  myConfig = {
    users.ui.enable = true;

    system = {
      home-manager.enable = true;
      home-manager.users = [ "ui" ];

      impermanence.enable = true;
      impermanence.device = "/dev/vda4";
    };

    boot.grub.enable = true;

    networking.networkmanager.enable = true;
    services.openssh.enable = true;

    programs = {
      doas.enable = true;
      bash.enable = true;
    };
  };
}
