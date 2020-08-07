#!/bin/bash
#
# This script installs the specified src-based python package
# at full path <packagepath> in <installmode> which is expected
# to be either "install" or "develop".
#
# Usage: install-src-package.sh <packagepath> <installmode>
#
set -o nounset -o errexit

packagepath=$1
installmode=$2

if [[ -z "$packagepath" ]]
then
    echo "Error: No package path given."
fi
if [[ -z "$installmode" ]]
then
    installmode="develop"
fi
# See https://github.com/illinois-ceesd/mirgecom/pull/43 for why this is not 'pip install -e .'
(cd $packagepath && python setup.py $installmode)
