{ fetchgit, linuxHelpers }:

with linuxHelpers.linux;

let

  source = prepareSource {
    version = "5.2.15";
    src = fetchgit {
      url = "https://github.com/raspberrypi/linux";
      rev = "bab1c236e844b0a891201c08b3da62dbedc10408";
      sha256 = "0s35hp3bai9sv0h0gkb21304mv79myb7ar50f4wfij7py833g6nc";
    };
    patches = with kernelPatches; [
      # ...
    ];
  };

  # config = makeConfig {
  #   inherit source;
  #   target = "bcm2711_defconfig";
  # };

  # $ nix-shell -A my-kernel.configEnv
  # $ mm # alias for make $makeFlags menuconfig
  # (navigate and set CONFIG_BINFMT_ELF=n)
  # $ ms # alias for make $makeFlags savedefconfig

  config = makeConfig {
    inherit source;
    target = "alldefconfig";
    allconfig = ./defconfig;
  };

in buildKernel rec {
  inherit source config;
  dtbs = true;
}
