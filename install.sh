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

myos=$(uname)
[[ $myos == "Darwin" ]] && myos="MacOSX"

myarch=$(uname -m)
have_conda=$(which conda || echo "notfound")

if [[ $have_conda == "notfound" ]]; then
    echo "==== Installing Miniforge."
    wget -c --quiet https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$myos-$myarch.sh
    bash Miniforge3-$myos-$myarch.sh -b
    export PATH=$HOME/miniforge3/bin:$PATH
else
    echo "==== Conda found, skipping Miniforge installation."
fi


echo "==== Installing conda packages"
conda init
conda activate
conda config --add channels conda-forge
conda update --all --yes
conda install --yes pocl clinfo

export OCL_ICD_VENDORS=$CONDA_PREFIX/etc/OpenCL/vendors/
echo 'export OCL_ICD_VENDORS=$CONDA_PREFIX/etc/OpenCL/vendors/' >> $HOME/.bashrc

echo "==== Installing pip packages"
pip install wheel pyvisfile numpy

for module in dagrt leap loopy meshmode grudge; do (cd $module && pip install -e .) ; done

echo
echo "############################################################"
echo "# Emirge is now installed. Please restart your shell       #"
echo "# and run mirgecom/wave-eager.py to test the installation. #"
echo "############################################################"
