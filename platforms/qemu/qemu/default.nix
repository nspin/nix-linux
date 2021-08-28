{ stdenv, lib, fetchurl, fetchgit
, python2, zlib, pkgconfig, glib
, ncurses, perl, pixman, vde2, texinfo, flex
, bison, lzo, snappy, libaio, gnutls, nettle, curl
, attr, libcap, libcap_ng

, targets ? []
}:

with lib;

stdenv.mkDerivation rec {

  pname = "qemu";
  version =  "4.2.0-rc0";
  src = fetchurl {
    url = "http://wiki.qemu.org/download/${pname}-${version}.tar.bz2";
    sha256 = "1hzlzkwrchjgd4msvb713b1wcngvs4i6a941rb3bayrmpc57hwd2";
  };

  nativeBuildInputs = [
    python2 pkgconfig perl
    texinfo flex bison
  ];

  buildInputs = [
    zlib glib ncurses pixman
    vde2 lzo snappy
    gnutls nettle curl
    libaio libcap_ng libcap attr
  ];

  hardeningDisable = [ "stackprotector" ];

  preConfigure = ''
    unset CPP # intereferes with dependency calculation
  '';

  configureFlags = [
    "--target-list=${lib.concatStringsSep "," targets}"
    "--enable-linux-aio"
    "--sysconfdir=/etc"
    "--localstatedir=$(out)/var" # or modify install target in Makefile
  ];

  doCheck = false; # tries to access /dev
  enableParallelBuilding = true;
}
