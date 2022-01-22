{ stdenv, overrideCC, lib, buildPackages, nukeReferences
, nettools, bc, bison, flex, perl, rsync, gmp, libmpc, mpfr, openssl, libelf, utillinux, kmod, sparse

, kconfigCommon
, configEnv, mkQueriable
}:

{ source
, config
, dtbs ? false
, modules ? true
, headers ? false
, kernelArch ? stdenv.hostPlatform.linuxArch
, kernelTarget ? stdenv.hostPlatform.linux-kernel.target
, kernelInstallTarget ?
    { uImage = "uinstall";
      zImage = "zinstall";
    }.${kernelTarget} or "install"
, kernelFile ? null
, cc ? null
, nukeRefs ? true
, passthru ? {}

# HACK: ignored, for nixos
, kernelPatches ? null
, features ? null
, randstructSeed ? null
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
    ] ++ lib.optionals headers [
      "hdrs"
    ];

    enableParallelBuilding = true;

    NIX_NO_SELF_RPATH = true;
    hardeningDisable = [ "all" ];

    depsBuildBuild = [
      buildPackages.stdenv.cc
      # for menuconfig in shell
      buildPackages.pkgconfig
      buildPackages.ncurses
    ];

    nativeBuildInputs = [
      bison flex bc perl
      nettools utillinux
      openssl gmp libmpc mpfr libelf
      kmod
    ] ++ lib.optionals nukeRefs [
      nukeReferences
    ] ++ lib.optionals headers [
      rsync
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
    ] ++ lib.optionals headers [
      "INSTALL_HDR_PATH=$(hdrs)"
    ];
      # "INSTALL_MOD_STRIP=1"

    installTargets = [
      kernelInstallTarget
    ] ++ lib.optionals modules [
      "modules_install"
    ] ++ lib.optionals dtbs [
      "dtbs_install"
    ] ++ lib.optionals headers [
      "headers_install"
    ];

    postInstall = ''
      release="$(cat $dev/include/config/kernel.release)"
    '' + lib.optionalString modules ''
      rm $mod/lib/modules/$release/{source,build}
    '' + lib.optionalString headers ''
      find $hdrs -name ..install.cmd -delete
    '' + lib.optionalString nukeRefs ''
      find $out -type f -exec nuke-refs {} \;
      find $mod -type f -exec nuke-refs {} \;
    '';

    passthru = {
      inherit source kernelArch;
      inherit (source) version;
      inherit stdenv moduleBuildDependencies;
      configFile = config;
      config = mkQueriable (kconfigCommon.readConfig config);
      kernel = "${self.out}/${kernelFile}";
      inherit kernelFile;
      modDirVersion = source.version;

      # HACK: for nixos
      override = lib.const self.mod;

      configEnv = configEnv {
        inherit source config;
      };

    } // passthru;

      shellHook = ''
        config=${config}
        source=$PWD
        obj=$PWD
        v() {
          echo "$@"
          "$@"
        }
        c() {
          cp -v --no-preserve=ownership,mode $config .config
        }
        s() {
          source=$(realpath ''${1:-.})
        }
        sap() {
          v sh ${self.source.stripAbsolutePaths} $source
        }
        m() {
          v make -C $source O=$obj ARCH=${kernelArch} ${lib.optionalString isCross "CROSS_COMPILE=${stdenv.cc.targetPrefix}"} -j$NIX_BUILD_CORES "$@"
        }
        mb() {
          v m ${lib.concatStringsSep " " self.buildFlags} "$@"
        }
        mi() {
          mkdir -pv $out $mod $dtbs $hdrs
          v m ${lib.concatMapStringsSep " " (x: "'${x}'") self.installFlags} ${lib.concatStringsSep " " self.installTargets} "$@"
        }
        export out=$PWD/out
        export mod=$PWD/mod
        export dtbs=$PWD/dtbs
        export hdrs=$PWD/hdrs
      '';

  };

in self
