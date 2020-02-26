{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {

  name = "soc_term";

  src = fetchFromGitHub {
    owner = "linaro-swg";
    repo = "soc_term";
    rev = "5493a6e7c264536f5ca63fe7511e5eed991e4f20";
    sha256 = "10c71apazaj3igcqn2ylpifnn9qssiswxixp9swxb7h71xd004aj";
  };

  postPatch = ''
    sed -i 's/gcc/$(CC)/g' Makefile
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp soc_term $out/bin
  '';

}
