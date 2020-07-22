#!/bin/bash

set -o errexit
# Conda does not like 'set -o nounset'

echo "#####################################################"
echo "# This script installs the dependencies for emirge. #"
echo "#####################################################"
echo

usage()
{
  echo "Usage: $0 [--prefix=DIR] [--modules] [--help]"
  echo "  --prefix=DIR      Install conda in non-default prefix."
  echo "  --modules         Create modules.zip and add to Python path."
  echo "  --help            Print this help text."
}

# Default conda location
conda_prefix=$HOME/miniforge3

# Build modules.zip? (via makezip.sh)
opt_modules=0

while [[ $# -gt 0 ]]; do
  arg=$1
  shift
  case $arg in
    --prefix=*)
        # Install conda in non-default prefix
        conda_prefix=${arg#*=}
        ;;
    --modules)
        # Create modules.zip
        opt_modules=1
        ;;
    --help)
        usage
        exit 0
        ;;
    *)
        usage
        exit 1
        ;;
  esac
done

# Conda does not like ~
conda_prefix=$(echo $conda_prefix | sed s,~,$HOME,)

export MY_CONDA_DIR=$conda_prefix

./install-conda.sh

export PATH=$MY_CONDA_DIR/bin:$PATH

echo "==== Create 'dgfem' conda environment"

conda create --name dgfem --yes

source $MY_CONDA_DIR/bin/activate dgfem

./install-conda-dependencies.sh
./install-pip-dependencies.sh


[[ $opt_modules -eq 1 ]] && ./makezip.sh

echo
echo "==================================================================="
echo "Emirge is now installed. Please run the following commands"
echo "to test the installation (assuming your shell is bash):"
echo " $ source $conda_prefix/bin/activate dgfem"
echo " $ python mirgecom/examples/wave-eager.py"
echo "==================================================================="
