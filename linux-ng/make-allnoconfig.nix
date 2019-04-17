{ stdenv, lib, buildPackages
, bison, flex
}:

{ source
, kernelArch ? stdenv.hostPlatform.platform.kernelArch
}:

let
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

in
stdenv.mkDerivation {

  name = "linux-config";

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ bison flex ];

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
  ];

  installPhase = ''
    runHook preInstall

    mv .config $out

    runHook postInstall
  '';

}
