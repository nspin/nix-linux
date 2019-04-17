let

  nixpkgs = import <nixpkgs> {
    crossSystem = {
      system = "aarch64-linux";
      config = "aarch64-unknown-linux-gnu";
    };
    overlays = [
      (import ../../overlay.nix)
    ];
  };

  inherit (nixpkgs) fetchgit linux-ng;

in with linux-ng; rec {

  inherit linux-ng;

  version = "5.0.3";

  source = doSource {
    inherit version;
    src = fetchgit {
      url = "https://github.com/raspberrypi/linux";
      rev = "ccb5e46a0f2faa3ec46f60acd051db2df8f068c0";
      sha256 = "1dhpmxs71vdhwlw7lfwha5fnh41j97imflip3d1zs75g5jp04jj9";
    };
    patches = with kernelPatches; [
      bridge_stp_helper
      many_modules
    ];
  };

  defconfig = getDefconfig {
    inherit source;
    defconfig = "bcmrpi3_defconfig";
  };

  allconfig = mergeConfig [
    (readConfig defconfig)
    (commonConfig { inherit version; })
    { LOCALVERSION = null; # remove an option that was set by bcmrpi3_defconfig
      DM_VERITY = "m"; # set another option
    }
  ];

  config = makeConfig {
    inherit source;
    allconfig = writeConfig allconfig;
  };

  kernel = doKernel rec {
    inherit source config;
    dtbs = true;
  };

}
