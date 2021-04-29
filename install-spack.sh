#!/bin/bash

set -o nounset -o errexit

echo "#####################################################"
echo "# This script installs the dependencies for emirge. #"
echo "#####################################################"
echo

have_spack=$(command -v spack || echo "notfound")

if [[ $have_spack == "notfound" ]]; then
    echo "==== Installing Spack."
    git clone https://github.com/spack/spack
    #shellcheck disable=SC1091
    source spack/share/spack/setup-env.sh

    echo "==== Configuring Spack to use E4S packages"
    spack mirror add E4S https://cache.e4s.io
    wget https://oaciss.uoregon.edu/e4s/e4s.pub
    spack gpg trust e4s.pub

    cd spack
    git checkout releases/latest
else
    echo "==== Spack found, skipping installation."
fi


echo "==== Installing spack packages"

spack install --cache-only pocl
spack load pocl

pocl_dir=$(spack find -p pocl| tail -1 | awk '{print $2}')

export OCL_ICD_VENDORS=$pocl_dir/etc/OpenCL/vendors/
#shellcheck disable=SC2016
echo 'export OCL_ICD_VENDORS=$pocl_dir/etc/OpenCL/vendors/' >> "$HOME/.bashrc"

./install-pip-dependencies.sh

echo
echo "#############################################################"
echo "# Emirge is now installed. Please run                       #"
echo "# mirgecom/examples/wave-eager.py to test the installation. #"
echo "#############################################################"
