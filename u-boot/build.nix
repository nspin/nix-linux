{ stdenv, lib, buildPackages, hostPlatform, buildPlatform
, bc, bison, dtc, flex, openssl, python2, swig
, configEnv
}:

{ source
, config
, kernelArch ? stdenv.hostPlatform.linuxArch
, filesToInstall ? [ "u-boot" "u-boot.bin" ]
, passthru ? {}
}:

let
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;
  passthru_ = passthru;

in stdenv.mkDerivation rec {

  name = "u-boot-${source.fullVersion}";

  phases = [ "configurePhase" "buildPhase" "installPhase" ];

  NIX_NO_SELF_RPATH = true;
  hardeningDisable = [ "all" ];

  # make[2]: *** No rule to make target 'lib/efi_loader/helloworld.efi', needed by '__build'.  Stop.
  enableParallelBuilding = false;

  depsBuildBuild = [
    buildPackages.stdenv.cc
    # for menuconfig in shell
    buildPackages.pkgconfig
    buildPackages.ncurses
  ];

  nativeBuildInputs = [ bc bison dtc flex ];

  configurePhase = ''
    cp -v ${config} .config
  '';

  makeFlags =  [
    "-C" "${source}"
    "O=$(PWD)"
    "DTC=dtc"
  ] ++ lib.optionals isCross [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  buildFlags = filesToInstall;

  installPhase = ''
    mkdir $out
    cp ${lib.concatStringsSep " " filesToInstall} $out
  '';

  passthru = {
    inherit source config;
    configEnv = configEnv {
      inherit source config;
    };
  } // passthru_;

  shellHook = ''
    config=${config}
    v() {
      echo "$@"
      "$@"
    }
    c() {
      cp -v --no-preserve=ownership,mode $config .config
    }
    sap() {
      v sh ${source.stripAbsolutePaths} "$@"
    }
    m() {
      v make DTC=dtc ${lib.optionalString isCross "CROSS_COMPILE=${stdenv.cc.targetPrefix}"} -j$NIX_BUILD_CORES "$@"
    }
    mb() {
      v m ${lib.concatStringsSep " " buildFlags} "$@"
    }
  '';

}

  # echo 'ccflags-y += -DDEBUG' >> scripts/Makefile.build
  # "CONFIG_DM_DEBUG=y"
