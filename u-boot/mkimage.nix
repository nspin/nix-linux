{ lib, runCommand, tools }:

{ name ? type
, type
, data
, compression ? "none"
, arch ? null
, os ? null
, address ? null
, entrypoint ? null
, xip ? false
}:

runCommand "${name}.uimg" {
  nativeBuildInputs = [ tools ];
  passthru = {
    inherit data;
  };
} ''
  mkimage ${lib.optionalString xip "-x"} -n ${name} -T ${type} -d ${data} -C ${compression} \
    ${lib.optionalString (arch != null) "-A ${arch}"} \
    ${lib.optionalString (os != null) "-O ${os}"} \
    ${lib.optionalString (address != null) "-a ${address}"} \
    ${lib.optionalString (entrypoint != null) "-e ${entrypoint}"} \
    $out
''
