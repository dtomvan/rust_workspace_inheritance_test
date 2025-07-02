{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs =
    { flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        nativeBuildInputs = with pkgs; [
          cargo
          rustc

          pkg-config
        ];
        buildInputs = with pkgs; [
          udev
          alsa-lib-with-plugins
          vulkan-loader

          xorg.libX11
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr

          libxkbcommon
          wayland
        ];
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          name = "rust_workspace_inheritance_test";
          version = "1.0";
          src = ./.;

          cargoHash = "sha256-UfVCFiKW0H51NKA/1twkI/m0SAZxJGVEwvJ5425aU/M=";

          inherit buildInputs nativeBuildInputs;
        };

        devShells.default = pkgs.mkShell {
          inherit buildInputs nativeBuildInputs;
        };
      }
    );
}
