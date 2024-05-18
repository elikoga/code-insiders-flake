{
  description = "Nix Flake for Code Insider";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };
  outputs =
    { self
    , nixpkgs
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      meta = builtins.fromJSON (builtins.readFile ./meta.json);
      package = (pkgs.vscode.override {
        isInsiders = true;
      }).overrideAttrs (oldAttrs: {
        pname = "vscode-insiders";
        src = (builtins.fetchurl {
          url = meta.url;
          sha256 = meta.sha256;
        });
        version = meta.version;
        meta.mainProgram = "code-insiders";
      });
    in
    {
      overlays.default = final: prev: {
        vscode-insiders = package;
      };
      packages.${system}.vscode-insider = package;
      legacyPackages.${system}.vscode-insider = package;
    };
}
