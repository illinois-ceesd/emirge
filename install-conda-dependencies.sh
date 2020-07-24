#!/bin/bash

set -o errexit

echo "==== Installing Conda packages for $(which conda)"

conda info --envs

conda install --yes pocl pyvisfile

# We need an MPI installation to build mpi4py.
# Install OpenMPI if none is available.
if ! command -v mpicc &> /dev/null ;then
    conda install --yes mpich mpich-mpicc

    mv $MY_CONDA_DIR/envs/dgfem/compiler_compat/ld $MY_CONDA_DIR/envs/dgfem/compiler_compat/ld_donotuse
    # source $MY_CONDA_DIR/bin/activate base
    # source $MY_CONDA_DIR/bin/activate dgfem
fi
