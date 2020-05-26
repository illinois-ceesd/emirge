#!/bin/bash

set -o nounset -o errexit

echo "#####################################################"
echo "# This script installs the dependencies for emirge. #"
echo "#####################################################"
echo

myos=$(uname)
[[ $myos == "Darwin" ]] && myos="MacOSX"

myarch=$(uname -m)

if [[ ! -d ~/miniforge3 ]]; then
    echo "Installing Miniforge"
    wget -c https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$myos-$myarch.sh
    bash Miniforge3-$myos-$myarch.sh -b
fi

conda update --all --yes
conda install --yes pocl

pip install pyvisfile

for module in dagrt grudge leap loopy meshmode; do (cd $module && pip install -e .); done
