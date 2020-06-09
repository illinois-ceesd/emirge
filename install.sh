#!/bin/bash

set -o nounset -o errexit

echo "#####################################################"
echo "# This script installs the dependencies for emirge. #"
echo "#####################################################"
echo

conda_prefix=$HOME/miniforge3

while [[ $# -gt 0 ]]; do
  arg=$1
  shift
  case $arg in
    --prefix=*)
        conda_prefix=${arg#*=}
        ;;
    *)
        echo "Usage: $0 [--prefix=DIR]"
        exit 1
        ;;
  esac
done

export MY_CONDA_DIR=$conda_prefix

./install-conda.sh

export PATH=$MY_CONDA_DIR/bin:$PATH

echo "==== Create 'dgfem' conda environment"
conda init
conda create --name dgfem --yes

$MY_CONDA_DIR/bin/activate dgfem

./install-conda-dependencies.sh
./install-pip-dependencies.sh

echo
echo "##############################################################"
echo "# Emirge is now installed. Please restart your shell and run #"
echo "# mirgecom/examples/wave-eager.py to test the installation.  #"
echo "##############################################################"
