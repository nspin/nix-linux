# TODO removeAttrs version

{ stdenv }:

{ src, version, extraVersion ? "", ... } @ args:

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
    runHook preInstall

    pushd $out
      for mf in $(find -name Makefile -o -name Makefile.include -o -name install.sh); do
          echo "stripping FHS paths in \`$mf'..."
          sed -i "$mf" -e 's|/usr/bin/||g ; s|/bin/||g ; s|/sbin/||g'
      done
    popd

    runHook postInstall
  '';

} // removeAttrs args [ "extraVersion" ] // {

  passthru = {
    inherit version extraVersion;
  };

})
