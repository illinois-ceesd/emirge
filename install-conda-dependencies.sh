#!/bin/bash

set -o nounset -o errexit

echo "==== Installing Conda packages"

conda update --all --yes
conda install --yes pocl numpy pyvisfile pyopencl

export OCL_ICD_VENDORS=$MY_CONDA_DIR/etc/OpenCL/vendors/
echo 'export OCL_ICD_VENDORS=$CONDA_PREFIX/etc/OpenCL/vendors/' >> $HOME/.bashrc
