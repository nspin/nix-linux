{ stdenv }:

{ src, version, extraVersion ? "", ... } @ args:

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

    pushd $out
      for mf in $(find -name Makefile -o -name Makefile.include -o -name install.sh); do
          echo "stripping FHS paths in \`$mf'..."
          sed -i "$mf" -e 's|/usr/bin/||g ; s|/bin/||g ; s|/sbin/||g'
      done
    popd

    runHook postFixup
  '';

} // removeAttrs args [ "version" "extraVersion" ] // {

  passthru = {
    inherit version extraVersion;
    fullVersion = version + extraVersion;
  };

})
