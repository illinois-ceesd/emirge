#!/bin/bash

# This script will install the conda packages specified by the user in
# "conda_packages.txt" or the default ones.

set -o errexit

echo "==== Installing Conda packages with $(which conda)"

conda info --envs

if [ -f conda_packages.txt ]
then
    printf "Found user-specified conda_packages.txt\n"
    conda_packages="$(cat conda_packages.txt)"
else
    printf "No conda_packages.txt found, installing default packages\n"
    conda_packages="pocl pyvisfile fparser matplotlib pep8 flake8"
fi
if ! command -v mpicc &> /dev/null ;then
    printf "No MPI found. Adding required MPI installation to conda.\n"
    conda_packages="${conda_packages} openmpi openmpi-mpicc"
fi
#    conda install --yes git pip pocl pyvisfile islpy pyopencl xmltodict fparser matplotlib pep8 flake8
for conda_package in $(cat conda_packages.txt)
do
    printf "Install conda package: ${conda_package}\n"
    if [ "${conda_package}" == ]
    conda install --yes ${conda_package}
done
