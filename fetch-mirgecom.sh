#!/bin/bash
set -o nounset -o errexit
mcbranch=$1
mcprefix=$2
# default it to branch=master, install=PWD
[[ -z "$mcbranch" ]] && mcbranch="master"
[[ -z "$mcprefix" ]] && mcprefix=$(pwd)
# create or populate mirgecom from repo
mcsrc=$mcprefix/mirgecom
if [[ -f "$mcsrc/setup.py" ]]
then   # mirgecom src already populated, checkout the right branch, pull it
    cd ${mcsrc} && git checkout ${mcbranch} && git pull
else   # clone specific branch to mirgecom src
    cd $mcprefix && git clone -b ${mcbranch} https://github.com/illinois-ceesd/mirgecom
fi
