{ stdenv, lib, buildPackages
, bison, flex
, ncurses
}:

{ source
, kernelArch ? stdenv.hostPlatform.platform.kernelArch
}:

let
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

in
stdenv.mkDerivation {

  name = "linux-kconfig-tools";

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];
  nativeBuildInputs = [
    bison flex
  ];

  phases = [ "buildPhase" "installPhase" ];

  makeFlags = [
    "-C" "${source}"
    "O=$(PWD)"
    "ARCH=${kernelArch}"
  ] ++ lib.optional isCross [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  buildFlags = [
    "allnoconfig"

    # "scripts/kconfig/conf"
    # "scripts/kconfig/menuconf"
  ];

  # buildFlags = [
  #   "scripts/kconfig/conf"
  # ];

  installPhase = ''
    mkdir -p $out/bin
    cp scripts/kconfig/conf $out/bin
  '';

}
