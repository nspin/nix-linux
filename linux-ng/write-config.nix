{ lib, writeText }:

config:

with lib;

# TODO quote at least when necessary

writeText "config"
  (concatStrings
    (mapAttrsToList (k: v: "CONFIG_${k}=${v}\n")
      (filterAttrs (k: v: v != null)
        config)))
