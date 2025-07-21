{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    devenv.url = "github:cachix/devenv";
    nix-gleam.url = "github:arnarg/nix-gleam";
  };

  outputs =
    inputs@{
      self,
      systems,
      nixpkgs,
      flake-parts,
      nix-gleam,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks-nix.flakeModule
        inputs.devenv.flakeModule
      ];

      systems = import inputs.systems;

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        let
          stdenv = pkgs.stdenv;

          twical = pkgs.buildGleamApplication {
            src = ./.;
          };

	  playwright-libpath = pkgs.lib.makeLibraryPath (
            with pkgs;
            [
              openssl
              systemd
              glibc
              glibc.dev
              glib
              cups.lib
              cups
              nss
              nssTools
              alsa-lib
              dbus
              at-spi2-core
              libdrm
              expat
              xorg.libX11
              xorg.libXcomposite
              xorg.libXdamage
              xorg.libXext
              xorg.libXfixes
              xorg.libXrandr
              xorg.libxcb
              mesa
              libxkbcommon
              pango
              cairo
              nspr
            ]
          );

          git-secrets' = pkgs.writeShellApplication {
            name = "git-secrets";
            runtimeInputs = [ pkgs.git-secrets ];
            text = ''
              git secrets --scan
            '';
          };
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              nix-gleam.overlays.default
            ];
            config = { };
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
            };

            settings.formatter = { };
          };

          pre-commit = {
            check.enable = true;
            settings = {
              hooks = {
                treefmt.enable = true;
                ripsecrets.enable = true;
                git-secrets = {
                  enable = true;
                  name = "git-secrets";
                  entry = "${git-secrets'}/bin/git-secrets";
                  language = "system";
                  types = [ "text" ];
                };
              };
            };
          };

          devenv.shells.default = {
            packages = with pkgs; [
	      nil
	      inotify-tools
              beamMinimal28Packages.rebar3
	      python313Packages.playwright
	      playwright-mcp
	    ];

            languages = {
              gleam = {
                enable = true;
               };
	      erlang = {
                enable = true;
	      };
	      javascript = {
                enable = true;
		npm.enable = true;
	      };
            };

            enterShell = '''';
          };

	  packages.default = twical;
        };
    };
}
