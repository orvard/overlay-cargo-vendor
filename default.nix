{}:

let
  hostpkgs = import <nixpkgs> {};

  pkgs = hostpkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "77560bb200a0fc9669d001755082bde787ceaf80";
    hash = "sha256-BCQFi7Mt6dXgK36lDP1Aaqdcmjlx9lPexmOpxfGYEXE=";
  };

  pinned = import pkgs {
    overlays = [
      (import ./overlay-fetch2.nix)
    ];
    config = {
      allowUnfree = true;
    };
  };

  rustPlatform = pinned.makeRustPlatform {
    inherit (pinned) cargo rustc;
  };

  #vendor = pinned.fetchCargoVendor {
  vendor = rustPlatform.fetchCargoVendor {
    name = "vendored";
    src = pinned.lib.cleanSource ./.;
    #hash = "sha256-mS4jO+HBYqVEWQO9PrzG08WI02NEP5NWcdhcpNhg8Jc=";
    hash = pinned.lib.fakeHash; #"sha256-DymUo949FuiU6800aw6sTfdxt6MbNRs3zOE1rirluFE=";
  };
in
  vendor
