{ config, pkgs, lib, inputs, ... }:

# TODO:
# direnv

{
  home.username = "ui";
  home.homeDirectory = "/home/ui";

  home.stateVersion = "23.11";

  programs.home-manager.enable = true;

  services.home-manager.autoUpgrade = {
    enable = true;
    frequency = "Sat *-*-* 13:20:00";
  };

  news.display = "silent";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    qmk
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
      })
  ];

  imports = [
    ./theme

    ./common/sh
    ./common/sh/bash.nix
    ./common/script
    ./common/xdg.nix

    ./common/apps/firefox
    ./common/apps/st.nix
    ./common/apps/neovim
    ./common/apps/zathura.nix
    ./common/apps/udiskie.nix
    ./common/apps/syncthing.nix
    ./common/apps/git.nix

    ./common/xserver
    ./common/xserver/dwm
  ];
}