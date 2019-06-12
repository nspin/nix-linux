{ stdenv, lib, buildPackages
, bison, flex
}:

{ source
, target
, allconfig ? null
, kernelArch ? stdenv.hostPlatform.platform.kernelArch
}:

let
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

in
stdenv.mkDerivation {

  name = "linux-${source.version}${source.extraVersion}-${target}.config";
  dontAddHostSuffix = true;

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ bison flex ];

  phases = [ "buildPhase" ];

  makeFlags = [
    "-C" "${source}"
    "O=$(PWD)"
    "ARCH=${kernelArch}"
  ] ++ lib.optionals isCross [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ] ++ lib.optionals (allconfig != null) [
    "KCONFIG_ALLCONFIG=${allconfig}"
  ] ++ [
    "KCONFIG_CONFIG=$(out)"
  ];

  buildFlags = [
    target
  ];

}
