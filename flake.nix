{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        fontsConf = pkgs.makeFontsConf {
          fontDirectories = [
            pkgs.font-awesome
            pkgs.fira
            pkgs.noto-fonts
            pkgs.roboto
          ];
        };
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            typst
          ];
          shellHook = ''
            export FONTCONFIG_FILE="${fontsConf}"
          '';
        };
      }
    );
}
