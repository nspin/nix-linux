{ lib, runCommand, writeText, python3
, dtb-helpers
}:

{ dtb, bootargs, initrd_start, initrd, stdout_path ? null, kaslr_seed ? null }:

let

  dtso_in = writeText "chosen.dtso.in" ''
    /dts-v1/;
    / {
      fragment@0 {
        target-path = "/";
        __overlay__ {
          chosen {
            bootargs = "${lib.concatStringsSep " " bootargs}";
            linux,initrd-start = <${initrd_start}>;
            linux,initrd-end = <@initrd_end@>;
            ${lib.optionalString (stdout_path != null) ''
              stdout-path = "${stdout_path}";
            ''}
            ${lib.optionalString (kaslr_seed != null) ''
              kaslr-seed = ${kaslr_seed};
            ''}
          };
        };
      };
    };
  '';

  dtso = runCommand "chosen.dtso" {
    nativeBuildInputs = [ python3 ];
  } ''
    initrd_size="$(stat --format %s ${initrd})"
    initrd_end="$(python3 -c "print(hex(${initrd_start} + $initrd_size))")"

    substitute ${dtso_in} $out --subst-var-by initrd_end $initrd_end
  '';

in
with dtb-helpers; applyOverlay dtb (compileOverlay dtso)
