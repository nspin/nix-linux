{ stdenv, buildPackages, rsync
}:

{ source
}:

stdenv.mkDerivation {

  name = "linux-headers-${source.fullVersion}";

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ rsync ];

  phases = [ "installPhase" ];

  makeFlags = [
    "-C" "${source}"
    "O=$(PWD)"
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
