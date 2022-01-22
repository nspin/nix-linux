{ stdenv, writeText }:

{ src, version, extraVersion ? "", ... } @ args:

let
  stripAbsolutePaths = writeText "strip-absolute-paths.sh" ''
    for mf in $(find "''${1:-.}" -name Makefile -o -name Makefile.include -o -name install.sh); do
        echo "stripping FHS paths in \`$mf'..."
        sed -i "$mf" -e 's|/usr/bin/||g ; s|/bin/||g ; s|/sbin/||g'
    done
  '';

in
stdenv.mkDerivation ({

  name = "uboot-source";

  phases = [ "unpackPhase" "patchPhase" "installPhase" "fixupPhase" ];

  installPhase = ''
    runHook preInstall

    root=$(pwd)
    cd $NIX_BUILD_TOP
    mv $root $out

    runHook postInstall
  '';

  fixupPhase = ''
    runHook preFixup

    patchShebangs $out/tools

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
