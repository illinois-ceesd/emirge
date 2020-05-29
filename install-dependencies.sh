#!/bin/bash

set -o nounset -o errexit

MY_MODULES="dagrt leap loopy meshmode grudge mirgecom"

for m in $MY_MODULES; do
    if [[ ! -f $m/setup.py ]]; then
        echo "==== ERROR: incomplete git clone. Please run:"
        echo "====   git submodule init && git submodule update"
        echo "==== to fetch emirge's submodules."
        exit 1
    fi
done

echo "==== Installing Conda packages"

conda update --all --yes
conda install --yes pocl numpy pyvisfile pyopencl

export OCL_ICD_VENDORS=$MY_CONDA_DIR/etc/OpenCL/vendors/
echo 'export OCL_ICD_VENDORS=$CONDA_PREFIX/etc/OpenCL/vendors/' >> $HOME/.bashrc

echo "==== Installing pip packages"

for module in $MY_MODULES; do 
    (cd $module && pip install --user -e .)
done
