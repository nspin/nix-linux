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

  name = "linux-config";

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ bison flex bc openssl ];

  phases = [ "configurePhase" "buildPhase" ];

  configurePhase = ''
    runHook preConfigure

    mkdir -p $out
    cp -v ${config} $out/.config

    runHook postConfigure
  '';

  makeFlags = [
    "-C" "${source}"
    "O=$(out)"
    "ARCH=${kernelArch}"
  ] ++ lib.optional isCross [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  buildFlags = [
    "modules.builtin"
    "include/config/kernel.release"
  ];

  # installPhase = ''
  #   runHook preInstall

  #   runHook postInstall
  # '';

  # fixupPhase = ''
  #   runHook preFixup

  #   runHook postFixup
  # '';

}
