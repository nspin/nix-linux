{ lib, fetchzip }:

let

  f = version: { vname, date, sha256 }:
    let
      basename = "${version}-raspbian-${vname}";
    in
      fetchzip {
        name = "raspbian-${version}.img";
        url = "http://downloads.raspberrypi.org/raspbian/images/raspbian-${date}/${basename}.zip";
        inherit sha256;
        extraPostFetch = ''
          mv $out/${basename}.img tmp
          rmdir $out
          mv tmp $out
        '';
        passthru = {
          inherit version;
        };
      };

in
lib.mapAttrs f {

  # The last Raspbian release for each kernel version:

  # Linux 3.18
  "2015-05-05" = {
    vname = "wheezy";
    date = "2015-05-07";
    sha256 = "1zqz0gm70zx3972s8wizzgwgxs682q1kjrgkyads0as5bfv3zz8b";
  };

  # Linux 4.1
  "2016-03-18" = {
    vname = "jessie";
    date = "2016-03-18";
    sha256 = "0rq3i7lqh5rsg56vyblhhrwrvi3wykh85iqf4hfhlll1mm62kf21";
  };

  # Linux 4.4
  "2016-11-25" = {
    vname = "jessie";
    date = "2016-11-29";
    sha256 = "0yrw6b8gw1c9bddfh8hfbsck4d11sl8ixlh96gr1i2jc10f9vbra";
  };

  # Linux 4.14
  "2018-11-13" = {
    vname = "stretch";
    date = "2018-11-15";
    sha256 = "0l9fwhcc18h8xwlmlicn3bn2n3zz4pd9lxvgv8iw7sh9pf1v3fa9";
  };

  # Linux 4.19
  "2019-06-20" = {
    vname = "buster";
    date = "2019-06-24";
    sha256 = "04dy1rgfljhlwgklsis45npqjdy4l9cmnzc3h96slpd1wpg1cmsg";
  };

  # Linux 4.19
  "2019-07-10" = {
    vname = "buster";
    date = "2019-07-12";
    sha256 = "14vz7v3pwsj6m6kz11qz4bw2cpd87s2wcbh6lizp8fazi0gdlkj6";
  };

}
