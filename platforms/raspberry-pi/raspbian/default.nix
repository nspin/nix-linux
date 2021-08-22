{ callPackage, lib }:

let
  mkBoot = callPackage ./mk-boot.nix {};
  images = callPackage ./images.nix {};

  f = version: image: {
    inherit image;
    boot = mkBoot image;
  };

  releases = lib.mapAttrs f images;

in
  releases // {
    latest = releases."2019-07-10";
  } // {
    inherit mkBoot;
  }
