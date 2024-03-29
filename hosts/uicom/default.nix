{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ../common/user/ui.nix

    ../common/nix.nix

    ../common/xserver/dwm.nix
    ../common/xserver/sddm.nix

    ../common/vm.nix
    ../common/podman.nix
    ../common/pipewire.nix
    ../common/fonts.nix
    ../common/bash.nix
    ../common/doas.nix
    ../common/udisks2.nix
    ../common/opentabletdriver.nix
  ];

  system.stateVersion = "23.11";

  boot.loader.systemd-boot.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    git
    gcc
  ];

  time.timeZone = "Asia/Taipei";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "uicom";
  networking.networkmanager.enable = true;
  # See https://github.com/NixOS/nixpkgs/issues/180175#issuecomment-1473408913
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # services.openssh.enable = true;

  # TODO: manage tailscale key etc
  services.tailscale.enable = true;


  # TODO: test this
  system.autoUpgrade = {
    enable = true;
    dates = "22:30";
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
  };

  nix.optimise = {
    automatic = true;
    dates = [ "23:00" ];
  };

  nix.gc = {
    automatic = true;
    dates = "Mon *-*-* 21:30:00";
    options = "--delete-older-than 7d";
  };
}
