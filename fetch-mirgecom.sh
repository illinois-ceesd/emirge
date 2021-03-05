#!/bin/bash
#
# This script simply grabs mirgecom from the CEESD repo (if necessary)
# puts it in <install_directory>/mirgecom, and makes the specified
# <branchname> current.
#
# Usage: fetch-mirgecom.sh <branchname> <install_directory>
#

set -o nounset -o errexit

# default it to branch=main, install=PWD
origin=$(pwd)
mcbranch="${1-main}"
mcprefix="${2-$origin}"

# create or populate mirgecom from repo
mcsrc="$mcprefix/mirgecom"

if [[ -f "$mcsrc/setup.py" ]]
then
    # mirgecom src already populated, checkout the right branch, pull it
    cd "$mcsrc"
    git checkout "$mcbranch"
    git pull
else
    # clone specific branch to mirgecom src
    cd "$mcprefix"
    git clone --branch "$mcbranch" https://github.com/illinois-ceesd/mirgecom
fi
