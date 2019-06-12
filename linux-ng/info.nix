{ stdenv, lib, buildPackages
, bison, flex, bc, openssl
}:

{ source
, config
, kernelArch ? stdenv.hostPlatform.platform.kernelArch
}:

let
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

in
stdenv.mkDerivation {

  name = "linux-info";

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ bison flex bc openssl ];

  phases = [ "configurePhase" "buildPhase" ];

  configurePhase = ''
    mkdir -p $out
  '';

  makeFlags = [
    "-C" "${source}"
    "O=$(out)"
    "ARCH=${kernelArch}"
  ] ++ lib.optional isCross [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ] ++ [
    "KCONFIG_CONFIG=${config}"
  ];

  buildFlags = [
    "modules.builtin"
    "include/config/kernel.release"
  ];

  # installPhase = ''
  # '';

  # fixupPhase = ''
  # '';

}
