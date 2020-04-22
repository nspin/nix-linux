self: super: with self;

let
  common = callPackage ./common {};

in {

  linux-ng = callPackage ./linux-ng {
    inherit common;
  };

  uboot-ng = callPackage ./uboot-ng {
    inherit common;
  };

  uboot-ng-tools = callPackage ./uboot-ng-tools {};
  uboot-ng-mkimage = callPackage ./uboot-ng-tools/mkimage.nix {};
  uboot-ng-mkimage-fit = callPackage ./uboot-ng-tools/mkimage-fit.nix {};

  dtb-helpers = callPackage ./dtb-helpers {};


  qemu-base = callPackage ./platforms/qemu/qemu { targets = []; };

  qemu-arm = qemu-base.override { targets = [ "arm-softmmu" ]; };
  qemu-aarch64 = qemu-base.override { targets = [ "aarch64-softmmu" ]; };
  qemu-x86_64 = qemu-base.override { targets = [ "x86_64-softmmu" ]; };

  qemu-aarch64-user = qemu-base.override { targets = [ "aarch64-linux-user" ]; };

  qemu-all = qemu-base.override {
    targets = [
      "arm-softmmu" "aarch64-softmmu" "x86_64-softmmu"
    ];
  };

  soc-term = callPackage ./platforms/qemu/soc-term {};


  raspbian = callPackage ./platforms/raspberry-pi/raspbian {};
  raspberry-pi-firmware = callPackage ./platforms/raspberry-pi/firmware {};

}
