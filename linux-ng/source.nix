{ stdenv, writeText }:

{ src, version, extraVersion ? "", ... } @ args:

let
  # TODO patchShebangs first
  stripAbsolutePaths = writeText "strip-absolute-paths.sh" ''
    for f in $(find "''${1:-.}" -name Makefile -o -name Makefile.include -o -name install.sh); do
      sed -i "$f" -e 's|/usr/bin/||g ; s|/bin/||g ; s|/sbin/||g'
    done
  '';

in
stdenv.mkDerivation ({

  name = "linux-source";

  phases = [ "unpackPhase" "patchPhase" "installPhase" "fixupPhase" ];

  installPhase = ''
    runHook preInstall

    root=$(pwd)
    cd $NIX_BUILD_TOP
    mv $root $out

    runHook postInstall
  '';

  # NOTE: DEPMOD is required to be an absolute path in scripts/depmod.sh for certain versions
  fixupPhase = ''
    runHook preFixup

    sh ${stripAbsolutePaths} $out

    runHook postFixup
  '';

} // removeAttrs args [ "version" "extraVersion" ] // {

  passthru = {
    inherit version extraVersion;
    fullVersion = version + extraVersion;
    inherit stripAbsolutePaths;
  };

})
