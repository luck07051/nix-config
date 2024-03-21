{ pkgs, ... }:

let
  script = { writeShellApplication, pkgs }:
    writeShellApplication {
      name = "tmuxinator-fzf";
      runtimeInputs = with pkgs; [ fzf tmux tmuxinator ];
      text = ''
        selected="$(tmuxinator list -n | tail -n +2 | fzf)"
        tmuxinator s "$selected"
      '';
    };
in {
  programs.tmux.tmuxinator.enable = true;

  home.packages = with pkgs; [
    (callPackage script { })
  ];

  home.shellAliases = {
    ts = "tmuxinator-fzf";
  };

  home.file.".config/tmuxinator".source = ./.;
}
