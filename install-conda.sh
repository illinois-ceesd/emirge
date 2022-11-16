#!/bin/bash

set -o nounset -o errexit

myos=$(uname)
myarch=$(uname -m)

# Use $HOME/miniforge3 by default
MY_CONDA_DIR=${MY_CONDA_DIR:-$HOME/miniforge3}

if [[ ! -d $MY_CONDA_DIR || ! -x $MY_CONDA_DIR/bin/conda ]]; then
    echo "==== Installing Mambaforge in $MY_CONDA_DIR."
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$myos-$myarch.sh"
    bash "Mambaforge-$myos-$myarch.sh" -u -b -p "$MY_CONDA_DIR"
else
    echo "==== Conda found in $MY_CONDA_DIR, skipping Mambaforge installation."
fi
