{ lib, callPackage }:

let

  # TODO use or work like merge_config.sh
  mergeConfig = with lib;
    foldl (x: y: x // y) {};

  isSubConfig = subconfig: config: with lib;
    all id
      (mapAttrsToList
        (k: v: (config.${k} or null) == v)
        subconfig);

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

  inherit mergeConfig isSubConfig;

  doSource = callPackage ./source.nix {};
  doHeaders = callPackage ./headers.nix {};
  doKernel = callPackage ./build.nix {
    inherit readConfig mkQueriable;
  };

  readConfig = callPackage ./read-config.nix {};
  writeConfig = callPackage ./write-config.nix {};
  makeConfig = callPackage ./make-config.nix {};
  getDefconfig = callPackage ./get-defconfig.nix {};
  saveDefconfig = callPackage ./save-defconfig.nix {};
  configEnv = callPackage ./config-env.nix {};

  getInfo = callPackage ./info.nix {};

  kernelPatches = {
    bridge_stp_helper = ./patches/bridge-stp-helper.patch;
    many_modules = ./patches/many-modules.patch;
    depmod_check = ./patches/depmod-check.patch;
  };

  commonConfig = callPackage ./common-config.nix {};

}
