{ stdenv, overrideCC, lib, buildPackages, nukeReferences
, nettools, bc, bison, flex, perl, rsync, gmp, libmpc, mpfr, openssl, libelf, utillinux, kmod, sparse
}:

{ source
, config
, kernelArch ? stdenv.hostPlatform.linuxArch
, cc ? null
}:

let
  stdenv_ = stdenv;
in

let
  stdenv = if cc == null then stdenv_ else overrideCC stdenv_ cc;

  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

in
stdenv.mkDerivation {

  name = "linux-dtbs-${source.fullVersion}";

  enableParallelBuilding = true;

  NIX_NO_SELF_RPATH = true;
  hardeningDisable = [ "all" ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [
    bison flex bc perl
    nettools utillinux
    openssl gmp libmpc mpfr libelf
    kmod
  ];

  phases = [ "configurePhase" "buildPhase" "installPhase" ];

  configurePhase = ''
    cp -v ${config} .config
  '';

  makeFlags =  [
    "-C" "${source}"
    "O=$(PWD)"
    "ARCH=${kernelArch}"
  ] ++ lib.optionals isCross [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  buildFlags = [
    "dtbs"
  ];

  installFlags = [
    "INSTALL_DTBS_PATH=$(out)"
  ];

  installTargets = [
    "dtbs_install"
  ];

}
