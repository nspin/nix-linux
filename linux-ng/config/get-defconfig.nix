{ stdenv }:

{ source
, kernelArch ? stdenv.hostPlatform.platform.kernelArch
, defconfig ? "defconfig"
}:

"${source}/arch/${kernelArch}/configs/${defconfig}"
