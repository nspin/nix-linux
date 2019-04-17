{ runCommand, buildPackages }:

configFile:

import (runCommand "config.nix" {} ''
  ${buildPackages.python3}/bin/python ${./read_config.py} < ${configFile} > $out
'').outPath
