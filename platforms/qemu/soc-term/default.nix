{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {

  name = "soc_term";

  src = fetchFromGitHub {
    owner = "linaro-swg";
    repo = "soc_term";
    rev = "5ac0645575bff3df26ca55c717bcde4b4c913d87";
    sha256 = "sha256-ZXgbNe0VcSbiApVfjWWSEB30OEsHkWPUiS6KfLfIKlU=";
  };

  installPhase = ''
    install -D -t $out/bin soc_term
  '';
}
