{
  description = "A Nix flake for templates";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }:
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
      };
    };
}
