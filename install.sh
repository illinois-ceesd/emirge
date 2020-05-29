#!/bin/bash

set -o nounset -o errexit

echo "#####################################################"
echo "# This script installs the dependencies for emirge. #"
echo "#####################################################"
echo

myos=$(uname)
[[ $myos == "Darwin" ]] && myos="MacOSX"

myarch=$(uname -m)

MY_CONDA_DIR=$HOME/miniforge3

if [[ ! -d $MY_CONDA_DIR ]]; then
    echo "==== Installing Miniforge in $MY_CONDA_DIR."
    wget -c --quiet https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$myos-$myarch.sh
    bash Miniforge3-$myos-$myarch.sh -b -p $MY_CONDA_DIR
    
else
    echo "==== Conda found in $MY_CONDA_DIR, skipping Miniforge installation."
fi

export PATH=$MY_CONDA_DIR/bin:$PATH

echo "==== Installing conda packages"
conda init
conda create -n dgfem --yes

$MY_CONDA_DIR/bin/activate dgfem

conda update --all --yes
conda install --yes pocl clinfo

export OCL_ICD_VENDORS=$MY_CONDA_DIR/etc/OpenCL/vendors/
echo 'export OCL_ICD_VENDORS=$CONDA_PREFIX/etc/OpenCL/vendors/' >> $HOME/.bashrc

./install-pip.sh

echo
echo "##############################################################"
echo "# Emirge is now installed. Please restart your shell and run #"
echo "# mirgecom/examples/wave-eager.py to test the installation.  #"
echo "##############################################################"
