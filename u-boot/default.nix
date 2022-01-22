{ lib, callPackage, otherSplices }:

rec {

  getDefconfig = callPackage ./config/get-defconfig.nix {};
  makeConfig = callPackage ./config/make-allconfig.nix {};
  configEnv = callPackage ./config/env.nix {};

  savedefconfig = callPackage ./config/make-savedefconfig.nix {};
  olddefconfig = callPackage ./config/make-olddefconfig.nix {};

  prepareSource = callPackage ./prepare-source.nix {};
  build = callPackage ./build.nix {
    inherit configEnv;
  };
  buildTools = callPackage ./build-tools.nix {
    inherit configEnv;
  };

  tools = callPackage ./tools {
    inherit prepareSource makeConfig buildTools;
  };
  mkImage = callPackage ./mkimage.nix {
    inherit (otherSplices.selfBuildHost.uBoot) tools;
  };
  mkImageFit = callPackage ./mkimage-fit.nix {
    inherit (otherSplices.selfBuildHost.uBoot) tools;
  };

}
