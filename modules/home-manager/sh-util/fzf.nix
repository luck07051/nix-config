{ config, lib, ... }:

with lib;

let
  cfg = config.myConfig.sh-util.fzf;
in {
  options.myConfig.sh-util.fzf = {
    enable = mkEnableOption "fzf";
  };

  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;

      defaultOptions = [
        "--height 50%"
        "--color=pointer:5,gutter:-1"
        "--no-separator"
        "--info=inline"
        "--reverse"
      ];

      defaultCommand = "fd -HL --exclude '.git' --type file";

      # TODO: theme support
      # color = {}
    };
  };
}
