#!/bin/bash

set -o nounset -o errexit

echo "==== Installing Conda packages for $(which conda)"

conda info --envs

conda install --yes pocl pyvisfile

# We need an MPI installation to build mpi4py.
# Install OpenMPI if none is available.
if [[ $(which mpicc) ]]; then
    conda install --yes openmpi
fi
