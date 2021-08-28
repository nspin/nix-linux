{ callPackage, lib }:

let
  mkBoot = callPackage ./mk-boot.nix {};
  images = callPackage ./images.nix {};

  f = version: image: {
    inherit image;
    boot = mkBoot {
      img = "${image}/${image.img}";
      inherit (image) version;
    };
  };

  releases = lib.mapAttrs f images;

in
  releases // {
    latest = releases."2021-05-07";
  } // {
    inherit mkBoot;
  }
