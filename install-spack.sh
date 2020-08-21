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
else
    echo "==== Spack found, skipping installation."
fi


echo "==== Installing spack packages"

spack install pocl
spack load pocl

pocl_dir=$(spack find -p pocl| tail -1 | awk '{print $2}')

export OCL_ICD_VENDORS=$pocl_dir/etc/OpenCL/vendors/
#shellcheck disable=SC2016
echo 'export OCL_ICD_VENDORS=$pocl_dir/etc/OpenCL/vendors/' >> "$HOME/.bashrc"

echo "==== Installing pip packages for general development (requirements_dev.txt)"

python -m pip install -r requirements_dev.txt


echo "==== Installing packages for mirgecom (requirements.txt)"

grep -v 'pyopencl' requirements.txt >> .req
python -m pip install -r .req --src .
rm -f .req

echo
echo "#############################################################"
echo "# Emirge is now installed. Please run                       #"
echo "# mirgecom/examples/wave-eager.py to test the installation. #"
echo "#############################################################"
