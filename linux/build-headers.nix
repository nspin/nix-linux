{ stdenv, lib, buildPackages, rsync
}:

{ source
, kernelArch ? stdenv.hostPlatform.linuxArch
}:

let
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

in
stdenv.mkDerivation {

  name = "linux-headers-${source.fullVersion}";

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ rsync ];

  phases = [ "installPhase" ];

  makeFlags = [
    "-C" "${source}"
    "O=$(PWD)"
    "ARCH=${kernelArch}"
  ] ++ lib.optionals isCross [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  installFlags = [
    "INSTALL_HDR_PATH=$(out)"
  ];

  installTargets = [
    "headers_install"
  ];

  postInstall = ''
    find $out -name ..install.cmd -delete
  '';
    # echo "${version}" > $out/include/config/kernel.release

}
