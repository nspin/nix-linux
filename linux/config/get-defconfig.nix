{ stdenv }:

{ source
, kernelArch ? stdenv.hostPlatform.linuxArch
, defconfig ? "defconfig"
}:

"${source}/arch/${kernelArch}/configs/${defconfig}"
