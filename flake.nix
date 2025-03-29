{
  description = "A Nix flake for templates";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    rec {
      defaultTemplate = templates.basic;
      templates = rec {
        default = basic;
        basic = {
          path = ./basic;
          description = "very basic nix flake template";
          welcomeText = ''
            	  Provides a basic dev shell with multi systems already setup.

            	  edit buildInputs for your projects dependencies
            	  '';
        };
        ocaml = {
          path = ./ocaml;
          description = "basic OCaml project template";
        };
        rust = {
          path = ./rust;
          description = "rust project template";
          welcomeText = ''
            	  Provides rust project with crane setup.

            	  Default package is 'app'
            	  '';
        };
        terraform = {
          path = ./terraform;
          description = "basic terraform project template";
        };
        python = {
          path = ./python;
          description = "python project template using uv2nix";
          welcomeText = ''
            	  Provides python setup using uv2nix.

                Shell has:
                - uv
                - ruff
                - pyright
            	  '';
        };
      };
      formatter = forAllSystems (system: nixpkgsFor.${system}.nixpkgs-fmt);
    };
}
