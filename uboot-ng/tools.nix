{ stdenv, lib, hostPlatform, buildPlatform
, bison, flex, openssl
, configEnv
}:

{ source
, config
, passthru ? {}
}:

let
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

in stdenv.mkDerivation {

  name = "u-boot-tools-${source.fullVersion}";

  phases = [ "configurePhase" "buildPhase" "installPhase" ];

  nativeBuildInputs = [ bison flex openssl ];

  configurePhase = ''
    cp -v ${config} .config
  '';

  makeFlags =  [
    "-C" "${source}"
    "O=$(PWD)"
  ] ++ lib.optionals isCross [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ] ++ [
    "NO_SDL=1"
    # "HOST_TOOLS_ALL=y"
    # "CROSS_BUILD_TOOLS=1"
  ];

  buildFlags = [
    "cross_tools"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp tools/{dumpimage,fdtgrep,mkenvimage,mkimage} $out/bin
  '';

  passthru = {
    inherit source config;
    configEnv = configEnv {
      inherit source config;
    };
  } // passthru;

}
