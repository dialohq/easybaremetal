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
            src = ./.;
            npmDepsHash = "sha256-497G4bgt+2O5YzGvoevps9xmImf38ZYbpuG99Hs5DlQ=";
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
