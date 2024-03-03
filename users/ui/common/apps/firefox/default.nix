{ inputs, pkgs, ... }:

# TODO:
# [x] cookie exceptions
# [x] plugin settings
# [-] firefox view (left toolbar)
# [-] search suggest (settings dont works)
# bookmark (local or here)
# containers (use or not)
# vim keybind
# new page to home

{
  imports = [
    ./profile_ui.nix

    inputs.arkenfox.hmModules.default
  ];

  nixpkgs.overlays = [
    inputs.nur.overlay
  ];

  home.sessionVariables = {
    BROWSER = "firefox";
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };

  programs.firefox = {
    enable = true;
    arkenfox = {
      enable = true;
      # version = "123.0";
    };
  };
}