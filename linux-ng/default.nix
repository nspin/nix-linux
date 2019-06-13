{ lib, callPackage, common }:

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
lib.fix (self: with self; common // {

  getDefconfig = callPackage ./config/get-defconfig.nix {};
  makeConfig = callPackage ./config/make-allconfig.nix {};
  configEnv = callPackage ./config/env.nix {};

  savedefconfig = callPackage ./config/make-savedefconfig.nix {};
  olddefconfig = callPackage ./config/make-olddefconfig.nix {};

  doSource = callPackage ./source.nix {};
  doHeaders = callPackage ./headers.nix {};
  doKernel = callPackage ./build.nix {
    inherit readConfig mkQueriable;
  };
  doDtbs = callPackage ./dtbs.nix {};

  getInfo = callPackage ./info.nix {};

  kernelPatches = {
    bridge_stp_helper = ./patches/bridge-stp-helper.patch;
    many_modules = ./patches/many-modules.patch;
    depmod_check = ./patches/depmod-check.patch;
  };

  nixosCommonConfig = callPackage ./nixos-common-config.nix {};

})
