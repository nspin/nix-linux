{ stdenv, lib, buildPackages
, bison, flex
}:

{ source
, config
, args
, kernelArch ? stdenv.hostPlatform.linuxArch
}:

let
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

in
stdenv.mkDerivation {

  name = "linux-${source.version}${source.extraVersion}.config";

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ bison flex ];

  phases = [ "buildPhase" ];

  buildPhase = ''
    cat ${config} > $out
    bash ${source}/scripts/config --file $out ${lib.concatStringsSep " " args}
  '';

}
