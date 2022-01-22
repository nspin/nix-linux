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

  name = "linux-${source.version}${source.extraVersion}-savedefconfig.config";

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ bison flex ];

  phases = [ "buildPhase" "installPhase" ];

  makeFlags = [
    "-C" "${source}"
    "O=$(PWD)"
    "ARCH=${kernelArch}"
  ] ++ lib.optionals isCross [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ] ++ [
    "KCONFIG_CONFIG=${config}"
  ];

  buildFlags = [
    "savedefconfig"
  ];

  installPhase = ''
    mv defconfig $out
  '';

}
