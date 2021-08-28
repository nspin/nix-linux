{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "raspberry-pi-firmware";
  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "firmware";
    rev = "24f05a6e0eadcf001159e3618759cfb51761fd0e";
    sha256 = "sha256-w+MF90boIxXGGAbJ0ei++OVtEKkZ3elq5HkQQKje0dk=";
  };
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mv boot $out
  '';
}
