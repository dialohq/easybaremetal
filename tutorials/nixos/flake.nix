{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };
  outputs = {
    self,
    nixpkgs,
    ...
  }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
        ./k3s.nix
        ./vm.nix
      ];
    };
  };
}
