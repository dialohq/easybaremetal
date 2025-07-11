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
      blogImage = self.packages.${system}.docker-blog;
      makers = (import ./infra/helpers.nix {inherit (pkgs) lib;}).makers;
    in {
      packages = {
        # kubenix definitions of Kubernetes cluster
        kubenix = kubenix.packages.${pkgs.system}.default.override {
          module = {kubenix, ...}: {
            imports = [
              kubenix.modules.k8s
              ./infra/cert-manager.nix

              # deploying the blog website from the "docker-blog" package below, with a helper function
              (makers.mkBasicDeployment {
                name = "webapp";
                image = "${blogImage.imageName}:${blogImage.imageTag}";
                replicas = 2;
                targetPort = 3000;
                ingress-hosts = ["easybaremetal.com" "www.easybaremetal.com"];
              })
            ];
          };
          specialArgs = {packages = self.packages.${system};};
        };

        # build/bundle the blog website as Nix package
        blog = pkgs.stdenv.mkDerivation {
          pname = "blog";
          version = "0.0.1";
          __noChroot = true;

          src = ./web;

          buildInputs = [pkgs.bun];

          buildPhase = ''
            bun i --frozen-lockfile
            bun run build
            mkdir $out
            cp -r dist/ $out/dist
            cp serve.ts $out/
          '';
        };

        # make a Docker image out of the "blog" package above
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
      };

      # simple development environment shell
      devShells.default = pkgs.mkShell {
        # get all of the packages from the "blog" package into the shell env
        inputsFrom = [self.packages.${system}.blog];
        # add some more packages to the shell env
        buildInputs = with pkgs; [
          alejandra
          kubernetes-helm
        ];
      };
    });
}
