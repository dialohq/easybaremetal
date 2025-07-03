{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/81bbc0eb0b178d014b95fc769f514bedb26a6127";
    flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b";
    kubenix.url = "github:hall/kubenix";
    nixidy.url = "github:dialohq/nixidy/d010752e7f24ddaeedbdaf46aba127ca89d1483a";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    kubenix,
    nixidy,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      # Manifests
      packages = {
        kubenix = kubenix.packages.${pkgs.system}.default.override {
          module = {kubenix, ...}: {
            imports = [./infra/cert-manager.nix ./infra/apps.nix];
          };
          specialArgs = {flake = self;};
        };
      };

      # Dev shell
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          alejandra
          bun
          kubernetes-helm
        ];
        # env.KUBECONFIG = "./k3s.yaml";
      };
    });
}
