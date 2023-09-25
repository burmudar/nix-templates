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
    {
      formatter = forAllSystems (system: nixpkgsFor.${system}.nixpkgs-fmt);
      templates = {
        basic = {
          path = ./basic;
          description = "very basic nix flake template";
	  welcomeText = ''
	  Provides a basic dev shell with multi systems already setup.

	  edit buildInputs for your projects dependencies
	  '';
        };
      };
    };
}
