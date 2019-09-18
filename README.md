# nixpkgs-linux-ng

This repository contains a framework for configuring and building Linux and U-Boot using Nixpkgs.
It also includes utilities for building out-of-tree kernel modules and various types of U-Boot images.

The infrastructure for configuring and building Linux within Nixpkgs is a beast: [nixpkgs/pkgs/os-specific/linux/kernel](https://github.com/NixOS/nixpkgs/tree/e79d20c16e1bfc7b0d59f7ebca7b930dc529db63/pkgs/os-specific/linux/kernel).
This project provides an alternative with a focus on minimalism and control.

### Tutorial

This tutorial shows how to build Linux for the Raspberry Pi 4 with a modified Kconfig and an out-of-tree module.
The full source of this example can be found in `./examples/rpi4`.

To get started, include `./overlay.nix` in your project.
This overlay provides the attribute `linux-ng`, among others.

Express the source of your kernel.
This expression can include patches and other hooks used by `stdenv`:
```nix
{
  source = linux-ng.doSource {
    version = "5.2.15";
    src = fetchgit {
      url = "https://github.com/raspberrypi/linux";
      rev = "bab1c236e844b0a891201c08b3da62dbedc10408";
      sha256 = "0s35hp3bai9sv0h0gkb21304mv79myb7ar50f4wfij7py833g6nc";
    };
    patches = with linux-ng.kernelPatches; [
      bridge_stp_helper
    ];
  };
}
```
Express the Kconfig of your kernel.
In this case, our Kconfig will be created from the `bcm2711_defconfig` make target.
Check out `./linux-ng/config/make-allconfig.nix` for the definition of `makeConfig`.
```nix
{
  config = linux-ng.makeConfig {
    inherit source;
    target = "bcm2711_defconfig";
  };
}
```
Build your kernel.
```nix
{
  kernel = linux-ng.doKernel rec {
    inherit source config;
    dtbs = true;
}
```
```
$ nix-build kernel
```
Modify your Kconfig using menuconfig to disable the ELF binary format (`CONFIG_BINFMT_ELF=n`).
This is done in an environment provided by nix-shell.
Check out `./linux-ng/config/env.nix` for the details of this environment.
```
$ nix-shell -A kernel.configEnv
$ mm # alias for make $makeFlags menuconfig
(navigate and set CONFIG_BINFMT_ELF=n)
$ ms # alias for make $makeFlags savedefconfig, creates a minimal ./defconfig
```
Update the kernel to use your modified Kconfig.
```nix
{
  config = makeConfig {
    inherit source;
    target = "alldefconfig";
    allconfig = ./defconfig;
  };
}
```
```
$ nix-build kernel
```
Build an out of tree module.
See `./linux-ng/examples/rpi4/module.nix` for an example.

### Plans

- Include helpers for manipulating device trees.
- Design and include utilities for programatically interacting with Kconfig
  (similar to those used in NixOS).
