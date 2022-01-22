self: super: with self; {

  linuxHelpers =
    let
      otherSplices = {
        selfBuildBuild = {};
        selfBuildHost = pkgsBuildHost.linuxHelpers;
        selfBuildTarget = {};
        selfHostHost = pkgsHostHost.linuxHelpers;
        selfTargetTarget = {};
      };
    in
      lib.makeScopeWithSplicing
        splicePackages
        newScope
        otherSplices
        (_: {})
        (_: {})
        (import ./scope.nix {
          inherit otherSplices;
        })
      ;

}
