{ stdenv, lib, buildPackages
, bison, flex
}:

{ source
, config ? null
, kernelArch ? stdenv.hostPlatform.platform.kernelArch
}:

let
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

in
stdenv.mkDerivation {

  name = "linux-config-env";

  depsBuildBuild = [
    buildPackages.stdenv.cc
    buildPackages.pkgconfig
    buildPackages.ncurses
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
