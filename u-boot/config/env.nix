{ stdenv, lib, buildPackages
, pkg-config, ncurses
, bison, flex
}:

{ source
, config ? null
, kernelArch ? stdenv.hostPlatform.linuxArch
}:

let
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

in
stdenv.mkDerivation {

  name = "u-boot-config-env";

  depsBuildBuild = [
    buildPackages.stdenv.cc
    pkg-config
    ncurses
  ];

  nativeBuildInputs = [ bison flex ];

  makeFlags = [
    "-C" "${source}"
    "O=$(PWD)"
    "ARCH=${kernelArch}"
  ] ++ lib.optional isCross [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  inherit source;

  shellHook = ''
    k() {
      export KCONFIG_CONFIG=$1
    }
    m() {
      make $makeFlags "$@"
    }
    mm() {
      m "$@" menuconfig
    }
    ms() {
      m "$@" savedefconfig
    }
  '' + lib.optionalString (config != null) ''
    cp -v --no-preserve=mode,ownership ${config} .config
  '';

}
