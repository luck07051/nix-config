{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.uimaConfig.system.xdg;
in
{
  options.uimaConfig.system.xdg = {
    enable = mkEnableOption "XDG";
  };

  config = mkIf cfg.enable rec {
    xdg.enable = true;
    xdg.mimeApps.enable = true;

    # .nix-profile
    nix.settings.use-xdg-base-directories = true;

    home.file = {
      # wget
      ".config/wgetrc".text = "hsts-file = ${config.xdg.cacheHome}/wget-hsts";
    };

    home.sessionVariables = {
      # .compose-cache
      XCOMPOSEFILE = "${config.xdg.cacheHome}/X11/xcompose";
      XCOMPOSECACHE = "${config.xdg.cacheHome}/X11/xcompose";

      # Cargo
      CARGO_HOME = "${config.xdg.dataHome}/cargo";

      # wget
      WGETRC = "${config.xdg.configHome}/wgetrc";
    };

  };
}
