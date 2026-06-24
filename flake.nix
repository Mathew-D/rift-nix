{
  description = "Rift flake package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system} = {
        rift = pkgs.callPackage ./pkgs/rift { };

        default = self.packages.${system}.rift;
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.rift}/bin/rift";
      };
    };
}
