#!/bin/bash

set -o nounset -o errexit

echo "#####################################################"
echo "# This script installs the dependencies for emirge. #"
echo "#####################################################"
echo

if [[ ! -f meshmode/setup.py ]]; then
	echo "ERROR: incomplete git clone. Please run:"
	echo "  git submodule init && git submodule update"
	echo "to fetch emirge's submodules."
	exit 1
fi

myos=$(uname)
[[ $myos == "Darwin" ]] && myos="MacOSX"

myarch=$(uname -m)

if [[ ! -d ~/miniforge3 ]]; then
    echo "Installing Miniforge"
    wget -c https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$myos-$myarch.sh
    bash Miniforge3-$myos-$myarch.sh -b
fi

export PATH=$PATH:~/miniforge3/bin
export OCL_ICD_VENDORS=~/miniforge3/etc/OpenCL/vendors/
echo 'export OCL_ICD_VENDORS=~/miniforge3/etc/OpenCL/vendors/' >> ~/.bashrc

echo "Installing conda packages"
conda init
conda update --all --yes
conda install --yes pocl clinfo

echo "Installing pip packages"
pip install pyvisfile

for module in dagrt leap loopy meshmode grudge; do (cd $module && pip install -e .); done

echo
echo "############################################################"
echo "# Emirge is now installed. Please restart your shell       #"
echo "# and run mirgecom/wave-eager.py to test the installation. #"
echo "############################################################"