#!/bin/bash

set -o errexit
# Conda does not like 'set -o nounset'

echo "#####################################################"
echo "# This script installs mirgecom, and dependencies.  #"
echo "#####################################################"
echo

usage()
{
  echo "Usage: $0 [--install-prefix=DIR] [--conda-prefix=DIR] [--branch=NAME]" 
  echo "                   [--modules] [--help]"
  echo "  --install-prefix=DIR  Install mirgecom in [DIR], (default=PWD)."
  echo "  --conda-prefix=DIR    Install conda in [DIR], (default=~/miniforge3)"
  echo "  --modules             Create modules.zip and add to Python path."
  echo "  --branch=NAME         Install specific branch of mirgecom (default=master)."
  echo "  --help                Print this help text."
}

# Default conda location
conda_prefix=$HOME/miniforge3
mcbranch="master"
mcprefix=$(pwd)

# Build modules.zip? (via makezip.sh)
opt_modules=0

while [[ $# -gt 0 ]]; do
  arg=$1
  shift
  case $arg in
    --install-prefix=*)
        # Install mirgecom in non-default prefix
        mcprefix=${arg#*=}
        ;;
    --conda-prefix=*)
        # Install conda in non-default prefix
        conda_prefix=${arg#*=}
        ;;
    --branch=*)
        # Install specified branch of mirgecom
        mcbranch=${arg#*=}
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
mcprefix=$(echo $mcprefix | sed s,~,$HOME,)
export EMIRGE_MIRGECOM_BRANCH=$mcbranch
export MY_CONDA_DIR=$conda_prefix

./install-conda.sh

export PATH=$MY_CONDA_DIR/bin:$PATH

echo "==== Create 'dgfem' conda environment"

# Make sure we get the just installed conda.
# See https://github.com/conda/conda/issues/10133 for details.
source $MY_CONDA_DIR/bin/activate

conda create --name dgfem --yes

source $MY_CONDA_DIR/bin/activate dgfem

if [ ! -d $mcprefix ]
then
    mkdir -p $mcprefix
fi
mcsrc=$mcprefix/mirgecom

./fetch-mirgecom.sh $mcbranch $mcprefix
./install-conda-dependencies.sh
./install-pip-dependencies.sh $mcsrc/requirements.txt $mcprefix
./install-src-package.sh $mcsrc

unset EMIRGE_MIRGECOM_BRANCH

[[ $opt_modules -eq 1 ]] && ./makezip.sh

echo
echo "==================================================================="
echo "Mirgecom is now installed in $mcsrc." 
echo "Before using this installation, one should load the appropriate"
echo "conda environment (assuming bash shell):"
echo " $ source $conda_prefix/bin/activate dgfem"
echo "Then, to test the installation:"
echo " $ cd $mcsrc/test && pytest *.py"
echo "To run the examples:"
echo " $ cd $mcsrc/examples && ./run_examples.sh ./"
echo "==================================================================="
