final: prev:

{
  # Override writers so that writePython3Bin is patched globally.
  # This is what actually reaches fetch-cargo-vendor.nix, since
  # makeRustPlatform calls it via callPackage with writers from pkgs scope.
  writers = prev.writers // {
    writePython3Bin = name: args: src:
      let
        patchedSrc =
          if name == "fetch-cargo-vendor-util"
          then builtins.replaceStrings
            [ "https://crates.io/api/v1/crates" ]
            [ "http://your-mirror.internal/api/v1/crates" ]
            src
          else src;
      in
        prev.writers.writePython3Bin name args patchedSrc;
  };

  # Something seems amiss with the setup for the diffutils tests...
  # I don't really care about running their tests...

  diffutils = prev.diffutils.overrideAttrs (old: {
    doCheck = false;
  });

  # Annoying doChecks everywhere for my rebuilds...
  ## stdenv = prev.stdenv // {
  ##   mkDerivation = args: prev.stdenv.mkDerivation ( args // {
  ##     doCheck = false;
  ##     doInstallCheck = false;
  ##   });
  ## };
}
