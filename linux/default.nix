{ lib, callPackage, kconfigCommon }:

let

  mkQueries = config: with lib; rec {
    isSet = attr: hasAttr attr config;
    getValue = attr: if isSet attr then getAttr attr config else null;
    isYes = attr: getValue attr == "y";
    isNo = attr: getValue attr == "n";
    isModule = attr: getValue attr == "m";
    isEnabled = attr: isModule attr || isYes attr;
    isDisabled = attr: !isSet attr || isNo attr;
  };

  mkQueriable = config: config // mkQueries config;

in
rec {

  getDefconfig = callPackage ./config/get-defconfig.nix {};
  makeConfig = callPackage ./config/make-allconfig.nix {};
  configEnv = callPackage ./config/env.nix {};

  savedefconfig = callPackage ./config/make-savedefconfig.nix {};
  olddefconfig = callPackage ./config/make-olddefconfig.nix {};

  modifyConfig = callPackage ./config/modify-config.nix {};

  prepareSource = callPackage ./prepare-source.nix {};
  buildHeaders = callPackage ./build-headers.nix {};
  buildDtbs = callPackage ./build-dtbs.nix {};
  buildKernel = callPackage ./build-kernel.nix {
    inherit kconfigCommon configEnv mkQueriable;
  };

  kernelPatches = {
    many_modules = ./patches/many-modules.patch;
    depmod_check = ./patches/depmod-check.patch;
    scriptconfig = ./patches/scriptconfig.patch;
  };

  mkModulesClosure = callPackage ./mk-modules-closure.nix {};
  aggregateModules = callPackage ./aggregate-modules.nix {};

}

  # buildInfo =
  #   buildFlags = [
  #     "modules.builtin"
  #     "include/config/kernel.release"
  #   ];
