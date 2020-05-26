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
    wget -c --quiet https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$myos-$myarch.sh
    bash Miniforge3-$myos-$myarch.sh -b
fi

export CONDA=$HOME/miniforge3
export PATH=$PATH:$HOME/miniforge3/bin
export OCL_ICD_VENDORS=$HOME/miniforge3/etc/OpenCL/vendors/
echo 'export OCL_ICD_VENDORS=$HOME/miniforge3/etc/OpenCL/vendors/' >> $HOME/.bashrc

echo "Installing conda packages"
bash -c 'conda init'
bash -c 'conda update --all --yes'
bash -c 'conda install --yes pocl clinfo'

echo "Installing pip packages"
bash -c 'pip install pyvisfile'

for module in dagrt leap loopy meshmode grudge; do bash -c "cd $module && pip install -e ."; done

echo
echo "############################################################"
echo "# Emirge is now installed. Please restart your shell       #"
echo "# and run mirgecom/wave-eager.py to test the installation. #"
echo "############################################################"
