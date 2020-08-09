#!/bin/bash
#
# This script installs the specified src-based python package
# at full path <packagepath> in <installmode> which is expected
# to be either "install" or "develop".
#
# Usage: install-src-package.sh <packagepath> <installmode>
#
set -o nounset -o errexit

if [[ $# -eq 0 ]]
then
    echo "install-src-package.sh:Error: No package path given."
    exit 1
fi
packagepath=$1
installmode="${2-develop}"

# See https://github.com/illinois-ceesd/mirgecom/pull/43 for why this is not 'pip install -e .'
(cd "$packagepath" && python setup.py "$installmode")
