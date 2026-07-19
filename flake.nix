# This flake is mostly a copy or an evolution of Urob's flake
# taken from [Urob's zmk-config](https://github.com/urob/zmk-config/tree/main)
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # This pins requirements.txt provided by zephyr-nix.pythonEnv.
    zephyr.url = "github:zmkfirmware/zephyr/v4.1.0+zmk-fixes";
    zephyr.flake = false;

    # Zephyr sdk and toolchain.
    zephyr-nix.url = "github:nix-community/zephyr-nix";
    zephyr-nix.inputs.zephyr.follows = "zephyr";
    zephyr-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Devicetree linter; use my fork for nix-package and ZMK-specific tweaks.
    # dts-linter.url = "github:urob/dts-linter/zmk";
    # dts-linter.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, zephyr-nix, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; };
    zephyr = zephyr-nix.packages.${system};

    libatomic = pkgs.runCommand "libatomic" {} ''
      mkdir -p $out/lib
      cp -d ${pkgs.stdenv.cc.cc.lib}/lib/libatomic.so* $out/lib/
    '';
  in {
    devShells.default = pkgs.mkShellNoCC {
    # devShells = forAllSystems (
      # system: let
        # pkgs = nixpkgs.legacyPackages.${system};
        # zephyr = zephyr-nix.packages.${system};
        # keymap_drawer = pkgs.python3Packages.callPackage ./nix/keymap-drawer.nix {};
        # dts-format = pkgs.callPackage ./nix/dts-format.nix {
          # dts-linter = dts-linter.packages.${system}.dev;
        # };
        # libatomic = pkgs.runCommand "libatomic" {} ''
        #   mkdir -p $out/lib
        #   cp -d ${pkgs.stdenv.cc.cc.lib}/lib/libatomic.so* $out/lib/
        # '';

          packages = with pkgs;
            [
              zephyr.pythonEnv
              (zephyr.sdk-0_16.override {targets = ["arm-zephyr-eabi"];})

              cmake
              dtc
              gcc
              ninja

              just
              yq # Make sure yq resolves to python-yq.

              # keymap_drawer
              # dts-format

              # -- Used by just_recipes and west_commands. Most systems already have them. --
              # pkgs.gawk
              # pkgs.unixtools.column
              # pkgs.coreutils # cp, cut, echo, mkdir, sort, tail, tee, uniq, wc
              # pkgs.diffutils
              # pkgs.findutils # find, xargs
              # pkgs.gnugrep
              # pkgs.gnused

            ];

          env = {
            PYTHONPATH = "${zephyr.pythonEnv}/${zephyr.pythonEnv.sitePackages}";
          };

          shellHook = ''
            export ZMK_BUILD_DIR=$(pwd)/.build;
            export ZMK_CONFIG_DIR=$(pwd)/config;
            export ZMK_SRC_DIR=$(pwd)/zmk/app;
            export LD_LIBRARY_PATH="${libatomic}/lib";
          '';
        };
      });
}
