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
    src = pinned.lib.cleanSource ./.;
    #hash = "sha256-mS4jO+HBYqVEWQO9PrzG08WI02NEP5NWcdhcpNhg8Jc=";
    hash = "sha256-mS4jO+HBYqVEWQO9PrzG08WI02NEP5NWcdhcpNhg8Jc="; #pinned.lib.fakeHash; #"sha256-DymUo949FuiU6800aw6sTfdxt6MbNRs3zOE1rirluFE=";
  };

  rust-project = rustPlatform.buildRustPackage {
    pname = "aaa";
    version = "1.0.0";
    src = ./.;

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

    # Maybe this is wrong..
    #meta = {
    #  pkgConfigModules = [
    #    libpcap
    #    zlib
    #  ];
    #};
  };
in
  rust-project
