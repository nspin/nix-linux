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

}
