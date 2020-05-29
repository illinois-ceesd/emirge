#!/bin/bash

set -o nounset -o errexit

echo "#####################################################"
echo "# This script installs the dependencies for emirge. #"
echo "#####################################################"
echo

have_spack=$(which spack || echo "notfound")

if [[ $have_spack == "notfound" ]]; then
    echo "==== Installing Spack."
    git clone https://github.com/spack/spack
    source spack/share/spack/setup-env.sh
else
    echo "==== Spack found, skipping installation."
fi


echo "==== Installing spack packages"

spack install pocl
spack load pocl

pocl_dir=$(spack find -p pocl| tail -1 | awk '{print $2}')

export OCL_ICD_VENDORS=$pocl_dir/etc/OpenCL/vendors/
echo 'export OCL_ICD_VENDORS=$pocl_dir/etc/OpenCL/vendors/' >> $HOME/.bashrc

./install-pip.sh

echo
echo "#############################################################"
echo "# Emirge is now installed. Please run                       #"
echo "# mirgecom/examples/wave-eager.py to test the installation. #"
echo "#############################################################"
