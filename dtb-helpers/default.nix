{ lib, runCommand, callPackage, dtc }:

rec {

  compile = compileWithName "dtb";
  compileOverlay = compileWithName "dtbo";

  compileWithName = name: dts: runCommand name {
    nativeBuildInputs = [ dtc ];
  } ''
    dtc -I dts -O dtb -o $out ${dts}
  '';

  decompile = decompileWithName "dts";

  decompileWithName = name: dtb: runCommand name {
    nativeBuildInputs = [ dtc ];
  } ''
    dtc -I dtb -O dts -o $out ${dtb}
  '';

  decompileForce = decompileForceWithName "dts";

  decompileForceWithName = name: dtb: runCommand name {
    nativeBuildInputs = [ dtc ];
  } ''
    dtc -f -I dtb -O dts -o $out ${dtb}
  '';

  applyOverlay = dtb: dtbo: applyOverlays dtb [ dtbo ];

  applyOverlays = dtb: dtbos: runCommand "dtb" {
    nativeBuildInputs = [ dtc ];
  } ''
    fdtoverlay -v -i ${dtb} -o $out ${lib.concatStringsSep " " dtbos}
  '';

  trivial = compile (builtins.toFile "trivial.dts" ''
    /dts-v1/;
    / { };
  '');

  catFiles = paths: runCommand "x" {} ''
    cat ${lib.concatStringsSep " " paths} > $out
  '';

  setChosen = callPackage ./set-chosen.nix {};

}
