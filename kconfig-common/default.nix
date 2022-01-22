{ lib, callPackage }:

{

  isSubConfig = subconfig: config: with lib;
    all id
      (mapAttrsToList
        (k: v: (config.${k} or null) == v)
        subconfig);

  readConfig = callPackage ./read-config.nix {};

}
