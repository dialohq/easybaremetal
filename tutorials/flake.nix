{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        packages = {
          sampleApp = pkgs.buildNpmPackage {
            name = "sample";
            buildInputs = [pkgs.nodejs_24];
            src = ./flake-app;
            npmDepsHash = "sha256-apQuXAe4cKRhHHi7TudStoJhoUEzJZ3e7+gOOFnfF34=";
            npmBuild = "npm run build";
            installPhase = ''
              mkdir $out
              cp -r public/ $out
              cp -r build/ $out
            '';
          };
        };
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_24
          ];
          shellHook = ''
            node --version
          '';
          env = {
            EDITOR = "hx";
          };
        };
      }
    );
}
