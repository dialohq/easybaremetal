{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    kubenix.url = "github:hall/kubenix";
  };
  outputs = {
    self,
    nixpkgs,
    kubenix,
    ...
  }: let
    system = "aarch64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    packages.${system} = {
      kubenix = kubenix.packages.${system}.default.override {
        module = {kubenix, ...}: {
          imports = [./cluster.nix kubenix.modules.k8s];
        };
      };
    };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        ./k3s.nix
        ./vm.nix
      ];
    };
  };
}
