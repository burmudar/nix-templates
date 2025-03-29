{
  description = "flake for rust development";

  # Nixpkgs / NixOS version to use.
  inputs= {
    nixpkgs.url = "github:NixOS/nixpkgs";
    unstable-nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    crane.url = "github:ipetkov/crane";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, unstable-nixpkgs, crane, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (localSystem:
      let
        overlays = [ rust-overlay.overlays.default ];
        pkgs = import nixpkgs {
          inherit overlays;
          system = localSystem;
        };

        lib = pkgs.lib;
        craneLib = (crane.mkLib pkgs);

        src = lib.cleanSourceWith {
          src = craneLib.path ./.;
          name = "source";
        };

        commonArgs = {
          inherit src;
          strictDeps = true;

          nativeBuildInputs = [
            pkgs.pkg-config
          ];

          buildInputs = [
            pkgs.glibc.dev
          ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
            pkgs.libiconv
            pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
          ];
        };
        cargoArtifacts = craneLib.buildDepsOnly (commonArgs);

        # Build the actual Rust package
        # this actually builds the package with `--release`
        app = craneLib.buildPackage (commonArgs // {
          inherit cargoArtifacts;
        });
        app-clippy = craneLib.cargoClippy (commonArgs // {
          inherit cargoArtifacts;
          cargoClippyExtraArgs = "-- -D warnings";
        });

        app-unit-tests = craneLib.mkCargoDerivation (commonArgs // {
          inherit cargoArtifacts;

          pnameSuffix = "-unit-tests";

          buildPhaseCargoCommand = "cargo test --verbose";
        });

      in
      {

        checks = {
          inherit app;
          inherit app-clippy;
          inherit app-unit-tests;

        };

        packages = {
          default = app;
        };


        formatter = pkgs.nixpkgs-fmt;

        devShells.default = craneLib.devShell (commonArgs // {
          packages = (commonArgs.nativeBuildInputs or [ ]) ++ (commonArgs.buildInputs or [ ]) ++ [
            pkgs.rust-analyzer
          ];

        });
      });
}
