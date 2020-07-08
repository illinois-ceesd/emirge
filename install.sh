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
conda init

# Attempt to also run conda init for the users shell (in case it is not bash):
which finger 2>/dev/null >/dev/null && conda init $(finger $USER | grep 'Shell:*' | cut -f3)

conda create --name dgfem --yes

source $MY_CONDA_DIR/bin/activate dgfem

./install-conda-dependencies.sh
./install-pip-dependencies.sh


[[ $opt_modules -eq 1 ]] && ./makezip.sh

echo
echo "#########################################################################"
echo "# Emirge is now installed. Please run the following commands            #"
echo "# to test the installation:                                             #"
echo "# $ exec bash (or whatever your shell is)                               #"
echo "# $ conda activate dgfem                                                #"
echo "# $ export OCL_ICD_VENDORS=$MY_CONDA_DIR/envs/dgfem/etc/OpenCL/vendors  #"
echo "# $ python mirgecom/examples/wave_eager.py                              #"
echo "#########################################################################"
