{ lib, runCommand, dtc, tools }:

{ name ? "fit"
, its
, dtc_options ? []
}:

runCommand "${name}.itb" {
  nativeBuildInputs = [ dtc tools ];
} ''
  mkimage -f ${its} ${lib.concatMapStringsSep " " (x: "-D ${x}") dtc_options} itb
  mv itb $out
''
