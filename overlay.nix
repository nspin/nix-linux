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

}
