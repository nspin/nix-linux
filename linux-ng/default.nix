{ lib, callPackage }:

let

  # TODO use or work like merge_config.sh
  mergeConfig = with lib;
    foldl (x: y: x // y) {};

  allPresent = subconfig: config: with lib;
    all id
      (mapAttrsToList (k: v: getAttr k config == v)
        (filterAttrs (k: v: v != null)
          subconfig));

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

  inherit mergeConfig allPresent;

  readConfig = callPackage ./read-config.nix {};
  writeConfig = callPackage ./write-config.nix {};

  doSource = callPackage ./source.nix {};

  getDefconfig = callPackage ./get-defconfig.nix {};
  makeConfig = callPackage ./make-config.nix {};
  makeAllnoconfig = callPackage ./make-allnoconfig.nix {};
  configEnv = callPackage ./config-env.nix {};

  getInfo = callPackage ./info.nix {};

  doHeaders = callPackage ./headers.nix {};
  doKernel = callPackage ./build.nix {
    inherit readConfig mkQueriable;
  };

  kernelPatches = {
    bridge_stp_helper = ./patches/bridge-stp-helper.patch;
    many_modules = ./patches/many-modules.patch;
    depmod_check = ./patches/depmod-check.patch;
  };

  commonConfig = callPackage ./common-config.nix {};

}
