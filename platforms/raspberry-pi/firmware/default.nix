{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "raspberry-pi-firmware";
  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "firmware";
    rev = "02bff4e75712094ffb1ab2ec58a8115ca3e52290";
    sha256 = "13g5xcqn1gwswjn8ciq6m3k8ch226g1q082xs1bp2h4zfmv0g3ry";
  };
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mv boot $out
  '';
}
