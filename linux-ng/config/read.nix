{ runCommand, buildPackages }:

config:

import (runCommand "config.nix" {} ''
  ${buildPackages.python3}/bin/python ${./read.py} < ${config} > $out
'').outPath
