{ stdenv, overrideCC, lib, buildPackages, nukeReferences
, nettools, bc, bison, flex, perl, rsync, gmp, libmpc, mpfr, openssl, libelf, utillinux, kmod, sparse

, configEnv, readConfig, mkQueriable
}:

{ source
, config
, dtbs ? false
, modules ? true
, kernelArch ? stdenv.hostPlatform.platform.kernelArch
, kernelTarget ? stdenv.hostPlatform.platform.kernelTarget
, kernelInstallTarget ?
    { uImage = "uinstall";
      zImage = "zinstall";
    }.${kernelTarget} or "install"
, kernelFile ? null
, cc ? null
, nukeRefs ? true
, passthru ? {}
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

    name = "linux-${source.fullVersion}";

    outputs = [
      "out" "dev"
    ] ++ lib.optionals modules [
      "mod"
    ] ++ lib.optionals dtbs [
      "dtbs"
    ];

    enableParallelBuilding = true;

    NIX_NO_SELF_RPATH = true;
    hardeningDisable = [ "all" ];

    depsBuildBuild = [ buildPackages.stdenv.cc ];
    nativeBuildInputs = [
      bison flex bc perl
      nettools utillinux
      openssl gmp libmpc mpfr libelf
      kmod
    ] ++ lib.optionals nukeRefs [
      nukeReferences
    ];

    phases = [ "configurePhase" "buildPhase" "installPhase" ];

    configurePhase = ''
      mkdir $dev
      cp -v ${config} $dev/.config
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
    ] ++ lib.optionals modules [
      "modules"
    ] ++ lib.optionals dtbs [
      "dtbs"
    ];

    installFlags = [
      "INSTALL_PATH=$(out)"
    ] ++ lib.optionals modules [
      "INSTALL_MOD_PATH=$(mod)"
    ] ++ lib.optionals dtbs [
      "INSTALL_DTBS_PATH=$(dtbs)"
    ];
      # "INSTALL_MOD_STRIP=1"

    installTargets = [
      kernelInstallTarget
    ] ++ lib.optionals modules [
      "modules_install"
    ] ++ lib.optionals dtbs [
      "dtbs_install"
    ];

    postInstall = ''
      release="$(cat $dev/include/config/kernel.release)"
    '' + lib.optionalString modules ''
      rm $mod/lib/modules/$release/{source,build}
    '' + lib.optionalString nukeRefs ''
      find $out -type f -exec nuke-refs {} \;
      find $mod -type f -exec nuke-refs {} \;
    '';

    passthru = {
      inherit source kernelArch;
      inherit (source) version;
      inherit stdenv moduleBuildDependencies;
      configFile = config;
      config = mkQueriable (readConfig config);
      kernel = "${self.out}/${kernelFile}";
      modDirVersion = source.version;
      configEnv = configEnv {
        inherit source config;
      };
    } // passthru;

  };

in self
