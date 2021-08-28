{ stdenvNoCC, mtools, utillinux }:

{ img, version }:

stdenvNoCC.mkDerivation rec {
  name = "raspios-${version}-boot";
  dontAddHostSuffix = true;

  phases = [ "installPhase" ];

  nativeBuildInputs = [
    mtools utillinux
  ];

  installPhase = ''
    sector=$(partx -g -r -n 1 -o START ${img})
    bytes=$(($sector * 512))
    # This usage is undocumented. I don't know how it works.
    mcopy -i ${img}@@$bytes -sv ::. $out
  '';

}
