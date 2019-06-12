{ runCommand, buildPackages }:

config:

import (runCommand "config.nix" {} ''
  ${buildPackages.python3}/bin/python ${./read_config.py} < ${config} > $out
'').outPath
