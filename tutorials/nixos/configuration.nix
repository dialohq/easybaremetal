{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  users.users.spike = {
    isNormalUser = true;
    home = "/home/spike";
    description = "Spike Spiegel";
    extraGroups = ["wheel" "networkmanager"];
    openssh.authorizedKeys.keys = ["..."];
  };
  environment.systemPackages = with pkgs; [
    helix
    btop
    cowsay
  ];
  networking.firewall.enable = false;
  services.openssh.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  system.stateVersion = "25.05";
}
