#!/bin/bash

set -o errexit
# Conda does not like 'set -o nounset'

echo "#####################################################"
echo "# This script installs the dependencies for emirge. #"
echo "#####################################################"
echo

# Default conda location
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

# Conda does not like ~
conda_prefix=$(echo $conda_prefix | sed s,~,$HOME,)

export MY_CONDA_DIR=$conda_prefix

./install-conda.sh

export PATH=$MY_CONDA_DIR/bin:$PATH

echo "==== Create 'dgfem' conda environment"
conda init

# Attempt to also run conda init for the users shell (in case it is not bash):
which finger 2>/dev/null >/dev/null && conda init $(finger $USER | grep 'Shell:*' | cut -f3)

conda create --name dgfem --yes

source $MY_CONDA_DIR/bin/activate dgfem

./install-conda-dependencies.sh
./install-pip-dependencies.sh

echo
echo "##############################################################"
echo "# Emirge is now installed. Please restart your shell and run #"
echo "# mirgecom/examples/wave-eager.py to test the installation.  #"
echo "##############################################################"
