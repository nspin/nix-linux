{ lib, callPackage, common }:

common // rec {

  getDefconfig = callPackage ./config/get-defconfig.nix {};
  makeConfig = callPackage ./config/make-allconfig.nix {};
  configEnv = callPackage ./config/env.nix {};

  savedefconfig = callPackage ./config/make-savedefconfig.nix {};
  olddefconfig = callPackage ./config/make-olddefconfig.nix {};

  doSource = callPackage ./source.nix {};
  doKernel = callPackage ./build.nix {
    inherit configEnv;
  };
  doTools = callPackage ./tools.nix {
    inherit configEnv;
  };

}
