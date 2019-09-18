let
  overlay = self: super: with self; {
    my-kernel = callPackage ./kernel.nix {};
    my-module = callPackage ./module.nix {
      kernel = my-kernel;
    };
  };

in import <nixpkgs> {
  crossSystem = {
    system = "aarch64-linux";
    config = "aarch64-unknown-linux-gnu";
  };
  overlays = [
    (import ../../overlay.nix)
    overlay
  ];
}
