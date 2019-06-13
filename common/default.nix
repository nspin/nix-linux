{ lib, callPackage }:

{

  # TODO use or work like merge_config.sh
  mergeConfig = with lib;
    foldl (x: y: x // y) {};

  isSubConfig = subconfig: config: with lib;
    all id
      (mapAttrsToList
        (k: v: (config.${k} or null) == v)
        subconfig);

  readConfig = callPackage ./read.nix {};
  writeConfig = callPackage ./write.nix {};

}
