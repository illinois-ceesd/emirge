#!/bin/bash

set -o nounset -o errexit

echo "#####################################################"
echo "# This script installs the dependencies for emirge. #"
echo "#####################################################"
echo

if [[ ! -f meshmode/setup.py ]]; then
    echo "==== ERROR: incomplete git clone. Please run:"
    echo "====   git submodule init && git submodule update"
    echo "==== to fetch emirge's submodules."
    exit 1
fi

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

echo "==== Installing pip packages"
pip install wheel pyvisfile numpy

for module in dagrt leap loopy meshmode grudge; do (cd $module && pip install -e .) ; done
EOF


echo
echo "####################################################"
echo "# Emirge is now installed. Please run              #"
echo "# mirgecom/wave-eager.py to test the installation. #"
echo "####################################################"
