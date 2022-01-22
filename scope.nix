{ otherSplices }:

self: with self;

{
  inherit otherSplices;

  kconfigCommon = callPackage ./common {};

  linux = callPackage ./linux {
    inherit kconfigCommon;
  };

  uBoot = callPackage ./u-boot {};

  dtbHelpers = callPackage ./dtb-helpers {};

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


  raspios = callPackage ./platforms/raspberry-pi/raspios {};
  raspberry-pi-firmware = callPackage ./platforms/raspberry-pi/firmware {};

}
