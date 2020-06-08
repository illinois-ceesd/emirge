#!/bin/bash

set -o nounset -o errexit

echo "==== Installing Conda packages"

conda install --yes pocl numpy pyvisfile pyopencl

#export OCL_ICD_VENDORS=$MY_CONDA_DIR/etc/OpenCL/vendors/

echo "To use the just-installed pocl, add the following line to your ~/.bashrc "
echo 'export OCL_ICD_VENDORS=$CONDA_PREFIX/etc/OpenCL/vendors/'
