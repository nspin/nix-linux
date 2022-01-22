{ runCommand, buildPackages }:

config:

import (runCommand "config.nix" {} ''
  ${buildPackages.python3}/bin/python ${./helper.py} < ${config} > $out
'').outPath
