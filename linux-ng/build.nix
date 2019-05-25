{ stdenv, overrideCC, lib, buildPackages, runCommand, writeScript, removeReferencesTo
, nettools, bc, bison, flex, perl, rsync, gmp, libmpc, mpfr, openssl, libelf, utillinux, kmod, sparse

, readConfig, mkQueriable
}:

{ source
, config
, dtbs ? false
, kernelArch ? stdenv.hostPlatform.platform.kernelArch
, kernelTarget ? stdenv.hostPlatform.platform.kernelTarget
, kernelInstallTarget ?
    { uImage = "uinstall";
      zImage = "zinstall";
    }.${kernelTarget} or "install"
, cc ? null
, kernelFile ? null
}:

let
  stdenv_ = stdenv;
  kernelFile_ = kernelFile;
in

let
  stdenv = if cc == null then stdenv_ else overrideCC stdenv_ cc;

  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

  # Dependencies that are required to build kernel modules
  moduleBuildDependencies = [
    libelf kmod sparse
  ];

  defaultKernelFile = "${if kernelTarget == "zImage" then "vmlinuz" else "vmlinux"}-${source.version}${source.extraVersion}";
  kernelFile = if kernelFile_ == null then defaultKernelFile else kernelFile_;

  self = stdenv.mkDerivation {

    name = "linux";

    outputs = [
      "out" "mod" "dev"
    ] ++ lib.optionals dtbs [
      "dtbs"
    ];

    enableParallelBuilding = true;
    requiredSystemFeatures = [ "big-parallel" ];

    NIX_NO_SELF_RPATH = true;
    hardeningDisable = [ "bindnow" "format" "fortify" "stackprotector" "pic" "pie" ];

    depsBuildBuild = [ buildPackages.stdenv.cc ];
    nativeBuildInputs = [
      bison flex bc perl
      nettools utillinux
      openssl gmp libmpc mpfr libelf
      kmod
    ];

    phases = [ "configurePhase" "buildPhase" "installPhase" ];

    configurePhase = ''
      runHook preConfigure

      mkdir -p $dev
      cp -v ${config} $dev/.config

      runHook postConfigure
    '';

    makeFlags =  [
      "-C" "${source}"
      "O=$(dev)"
      "ARCH=${kernelArch}"
    ] ++ lib.optionals isCross [
      "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    ];

    buildFlags = [
      kernelTarget
      "modules"
    ] ++ lib.optionals dtbs [
      "dtbs"
    ];

    installFlags = [
      "INSTALL_PATH=$(out)"
      "INSTALL_MOD_PATH=$(mod)"
    ] ++ lib.optionals dtbs [
      "INSTALL_DTBS_PATH=$(dtbs)"
    ];
      # "INSTALL_MOD_STRIP=1"

    installTargets = [
      kernelInstallTarget
      "modules_install"
    ] ++ lib.optionals dtbs [
      "dtbs_install"
    ];

    postInstall = ''
      release="$(cat $dev/include/config/kernel.release)"
      rm $mod/lib/modules/$release/{source,build}
    '';

    passthru = {
      inherit source kernelArch;
      inherit (source) version;
      inherit stdenv moduleBuildDependencies;
      configFile = config;
      config = mkQueriable (readConfig config);
      kernel = "${self}/${kernelFile}";
      modDirVersion = source.version;
    };

  };

in self
