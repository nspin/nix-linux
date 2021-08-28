{ lib, fetchzip }:

let

  f = version: { vname, date, sha256 }:
    let
      basename = "${version}-raspios-${vname}-armhf-lite";
    in
      fetchzip {
        name = "raspios-${version}.img";
        url = "http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-${date}/${basename}.zip";
        inherit sha256;
        passthru = {
          inherit version;
          img = "${basename}.img";
        };
      };

in
lib.mapAttrs f {

  "2021-05-07" = {
    vname = "buster";
    date = "2021-05-28";
    sha256 = "sha256-K2+FXT3FgTCJzQ8iE3c9wh898GZguJxuS3nJx/mtHaU=";
  };

}
