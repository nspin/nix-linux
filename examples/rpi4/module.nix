{ kernel, lib }:

let
  isCross = with kernel.stdenv; hostPlatform != buildPlatform;

in

kernel.stdenv.mkDerivation {

  name = "hello-module";

  NIX_NO_SELF_RPATH = true;
  hardeningDisable = [ "bindnow" "format" "fortify" "stackprotector" "pic" "pie" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  src = lib.cleanSource ./src;

  makeFlags =  [
    "C=${kernel.dev}"
    "ARCH=${kernel.kernelArch}"
  ] ++ lib.optionals isCross [
    "CROSS_COMPILE=${kernel.stdenv.cc.targetPrefix}"
  ];

  buildFlags = [
    "modules"
  ];

  installFlags = [
    "INSTALL_MOD_PATH=$(out)"
  ];

  installTargets = [
    "modules_install"
  ];

  postInstall = ''
    rm $out/lib/modules/*/modules.*
  '';

}
