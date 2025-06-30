{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/81bbc0eb0b178d014b95fc769f514bedb26a6127";
    flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          alejandra
          bun
        ];
      };
    });
}
