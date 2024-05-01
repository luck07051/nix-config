{ config, lib, pkgs, ... }:

# TODO: rootless?
# TODO: docker? lazydocker?

with lib;

let
  cfg = config.uimaConfig.virt.podman;
in
{
  options.uimaConfig.virt.podman = {
    enable = mkEnableOption "Podman";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      podman-compose
    ];

    virtualisation.podman = {
      enable = true;

      # Create a `docker` alias for podman
      # dockerCompat = true;
      # dockerSocket.enable = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
