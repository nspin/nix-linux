{ lib, writeText }:

config:

with lib;

writeText "config"
  (concatStrings
    (mapAttrsToList (k: v: "CONFIG_${k}=${v}\n")
      (filterAttrs (k: v: v != null)
        config)))
