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

          cargoHash = "sha256-YZtOlUNVUmWKn1vVroUyG9Fw+KeZZ3kQYVuq1/yi9+8=";

          inherit buildInputs nativeBuildInputs;
        };

        packages.cargoDeps =
          pkgs.runCommand "rust_workspace_inheritance_test-vendor"
            {
              nativeBuildInputs = with pkgs; [
                cargo
                cacert
              ];

              outputHash = "sha256-c8G8MDmdeE7XhmHU9KYPMtHpImilOeJ6/MNobIo7YWU=";
              outputHashMode = "recursive";
            }
            ''
              export HOME=`mktemp -d`
              cargo vendor \
                -Z unstable-options \
                --locked \
                --versioned-dirs \
                --manifest-path ${./.}/Cargo.toml \
                --lockfile-path ${./.}/Cargo.lock \
                $out
            '';

        devShells.default = pkgs.mkShell {
          inherit buildInputs nativeBuildInputs;
        };
      }
    );
}
