final: prev:

{
  fetchCargoVendor = prev.callPackage
    ({ lib
     , stdenvNoCC
     , runCommand
     , python3Packages
     , cargo
     , nix-prefetch-git
     , cacert
     , writers
     }:

      let
        patchedWriters = writers // {
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
              writers.writePython3Bin name args patchedSrc;
        };
      in

      import (prev.path + "/pkgs/build-support/rust/fetch-cargo-vendor.nix") {
        inherit
          lib
          stdenvNoCC
          runCommand
          python3Packages
          cargo
          nix-prefetch-git
          cacert;

        writers = patchedWriters;
      }
    )
    {};
}

