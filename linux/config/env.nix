{ stdenv, lib, buildPackages
, pkg-config, ncurses
, bison, flex
, python3Packages
}:

{ source
, config ? null
, kernelArch ? stdenv.hostPlatform.linuxArch
}:

let
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

in
stdenv.mkDerivation {

  name = "linux-config-env";

  depsBuildBuild = [
    buildPackages.stdenv.cc
    pkg-config
    ncurses
  ];

  nativeBuildInputs = [
    bison flex
    python3Packages.kconfiglib
  ];

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
    ma () {
      m KCONFIG_ALLCONFIG=defconfig "$@" alldefconfig
    }
    mp() {
      script=$1
      shift
      m scriptconfig SCRIPT=$script SCRIPT_ARGS="$*"
    }
    mpi() {
      script=$1
      shift
      m scriptconfig PYTHON_ARGS=-i SCRIPT=$script SCRIPT_ARGS="$*"
    }
  '' + lib.optionalString (config != null) ''
    cp -v --no-preserve=mode,ownership ${config} .config
  '';

}
