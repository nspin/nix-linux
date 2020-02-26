{ stdenvNoCC, mtools, utillinux }:

image:

stdenvNoCC.mkDerivation rec {
  name = "raspbian-${version}-boot";
  dontAddHostSuffix = true;

  phases = [ "installPhase" ];

  nativeBuildInputs = [
    mtools utillinux
  ];

  inherit image;
  inherit (image) version;

  installPhase = ''
    sector=$(partx -g -r -n 1 -o START $image)
    bytes=$(($sector * 512))
    # This usage is undocumented. I don't know how it works.
    mcopy -i $image@@$bytes -sv ::. $out
  '';

}
