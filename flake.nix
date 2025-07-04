{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b";
    kubenix.url = "github:hall/kubenix";
    nixidy.url = "github:dialohq/nixidy/d010752e7f24ddaeedbdaf46aba127ca89d1483a";
    nix2container.url = "github:nlewo/nix2container";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    kubenix,
    nixidy,
    nix2container,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      n2c = nix2container.packages.${system};
    in {
      packages = {
        kubenix = kubenix.packages.${pkgs.system}.default.override {
          module = {kubenix, ...}: {
            imports = [./infra/cert-manager.nix ./infra/apps.nix];
          };
          specialArgs = {packages = self.packages.${system};};
        };

        blog = pkgs.stdenv.mkDerivation {
          pname = "blog";
          version = "0.0.1";
          __noChroot = true;

          src = ./web;

          buildInputs = with pkgs; [bun];

          buildPhase = ''
            bun i --frozen-lockfile
            bun run build
            mkdir $out
            cp -r dist/ $out/dist
            cp serve.ts $out/
          '';
        };

        docker-blog = n2c.nix2container.buildImage {
          name = "ghcr.io/dialohq/easybaremetal";
          copyToRoot = [
            (pkgs.buildEnv {
              name = "root";
              paths = [pkgs.bun];
              pathsToLink = ["/bin"];
            })
            self.packages.${system}.blog
          ];
          config = {
            entrypoint = ["bun" "serve.ts"];
          };
        };

        nc = n2c;
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [self.packages.${system}.blog];
        buildInputs = with pkgs; [
          alejandra
          kubernetes-helm
        ];
        # env.KUBECONFIG = "./k3s.yaml";
      };
    });
}
