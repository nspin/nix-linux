{ stdenv, lib, buildPackages
, bison, flex
}:

{ source
, config
, kernelArch ? stdenv.hostPlatform.linuxArch
}:

let
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

in
stdenv.mkDerivation {

  name = "linux-${source.version}${source.extraVersion}-olddefconfig.config";

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ bison flex ];

  phases = [ "configurePhase" "buildPhase" ];

  configurePhase = ''
    cp ${config} $out
  '';

  makeFlags = [
    "-C" "${source}"
    "O=$(PWD)"
    "ARCH=${kernelArch}"
  ] ++ lib.optionals isCross [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ] ++ [
    "KCONFIG_CONFIG=$(out)"
  ];

  buildFlags = [
    "olddefconfig"
  ];

}
