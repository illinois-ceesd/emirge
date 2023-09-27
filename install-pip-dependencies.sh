#!/bin/bash

#
# This script reads the dependency package information from
# the caller-supplied <requirements_file> (presumably <package>/requirements.txt)
# and installs them by an appropriate method (i.e. as a development package)
# to the caller-supplied <install_location>, which defaults to the PWD.
#
# Usage: install-pip-dependencies <requirements_file> <install_location>
#

set -o nounset -o errexit

origin=$(pwd)
requirements_file="${1-mirgecom/requirements.txt}"
install_location="${2-$origin}"

mkdir -p "$install_location"

echo "==== Installing pip packages from $requirements_file"

# Semi-required for pyopencl
python -m pip install mako

# Semi-required for meshpy source install, avoids warning and wait
python -m pip install pybind11

# Some nice-to haves for development
python -m pip install pytest pudb flake8 pep8-naming flake8-quotes flake8-bugbear \
                      flake8-comprehensions pytest-pudb sphinx \
                      sphinx_math_dollar sphinx_copybutton furo


if [[ $(mpicc --version) == "IBM XL"* ]]; then
    echo "==== Emirge error: trying to build mpi4py with the XL compiler."
    echo "==== Load a gcc module (e.g. 'ml load gcc' on Lassen)."
    exit 1
fi


# Install the packages from the requirements file
export MPI4PY_BUILD_CONFIGURE=1
pip install --src . -r "$requirements_file"
