{}:

let
  hostpkgs = import <nixpkgs> {};

  # Pinned 2026-02-27
  pkgs = hostpkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "77560bb200a0fc9669d001755082bde787ceaf80";
    hash = "sha256-BCQFi7Mt6dXgK36lDP1Aaqdcmjlx9lPexmOpxfGYEXE=";
  };

  # Pinned 2026-02-27
  oxalica = hostpkgs.fetchFromGitHub {
    owner = "oxalica";
    repo = "rust-overlay";
    rev = "9b2965450437541d25fde167d8bebfd01c156cef";
    hash = "sha256-HmbcapTlcRqtryLUaJhH8t1mz6DaSJT+nxvWIl2bIPU=";
  };

  my-overlay = import ./overlay-fetch2.nix;

  pinned = import pkgs {
    overlays = [
      (import oxalica)
      # my-overlay
    ];
    config = {
      allowUnfree = true;
    };
  };

  rust-toolchain = pinned.rust-bin.nightly.latest.default.override {
    extensions = [
      "rust-src"
      "rust-std"
      "rust-docs"

      "rustc"
      "cargo"
      "rustfmt"
      "clippy"
    ];
    # target = [ "triplet" ];
  };

  rustPlatform = pinned.makeRustPlatform {
    cargo = rust-toolchain;
    rustc = rust-toolchain;
  };

  #vendor = pinned.fetchCargoVendor {
  vendor = rustPlatform.fetchCargoVendor {
    name = "vendored";
    src = pinned.lib.cleanSource ./nested-crate;
    hash = "sha256-OFztwgUhOX/nmMAIXSiT6vvhueXq7STBU29J+sEK7CE=";
  };

  rust-project = rustPlatform.buildRustPackage {
    pname = "aaa";
    version = "1.0.0";
    src = pinned.lib.cleanSource ./nested-crate;

    cargoDeps = vendor;

    nativeBuildInputs = with pinned; [
      rustPlatform.cargoSetupHook # might be broken?
      rustPlatform.bindgenHook

      pkg-config
    ];

    buildInputs = with pinned; [
      libpcap
      openssl
      zlib
    ];

  };
in
  rust-project
