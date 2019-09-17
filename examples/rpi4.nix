let

  nixpkgs = import <nixpkgs> {
    crossSystem = {
      system = "aarch64-linux";
      config = "aarch64-unknown-linux-gnu";
    };
    overlays = [
      (import ../overlay.nix)
    ];
  };

  inherit (nixpkgs) fetchgit linux-ng;

in with linux-ng; rec {

  source = doSource {
    version = "5.2.15";
    src = fetchgit {
      url = "https://github.com/raspberrypi/linux";
      rev = "bab1c236e844b0a891201c08b3da62dbedc10408";
      sha256 = "0s35hp3bai9sv0h0gkb21304mv79myb7ar50f4wfij7py833g6nc";
    };
    patches = with kernelPatches; [
      bridge_stp_helper
    ];
  };

  config = makeConfig {
    inherit source;
    target = "bcm2711_defconfig";
  };

  kernel = doKernel rec {
    inherit source config;
    dtbs = true;
  };

}
