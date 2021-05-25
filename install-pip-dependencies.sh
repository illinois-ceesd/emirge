#!/bin/bash

#
# This script reads the dependency package information from
# the caller-supplied <requirements_file> (presumably <package>/requirements.txt)
# and installs them by an appropriate method (i.e. as a development package)
# to the caller-supplied <install_location>, which defaults to the PWD.
#
# Usage: install-pip-dependencies <requirements_file> <install_location>
#

# Activate the env again, 'cause conda is fun.
# https://github.com/conda/conda/issues/10133
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get us a 'conda' command, activate our desired (but non-functional) env.
# The env is a frankenconda: an env is loaded, but using python from base.
# shellcheck source=/dev/null
source "$SCRIPT_DIR/config/activate_env.sh"
# Going once - deactivate the non-functional env:
conda deactivate
# Going twice - deactivate conda base env:
conda deactivate
# Going thrice - activate the desired env, now actually working:
# shellcheck source=/dev/null
source "$SCRIPT_DIR/config/activate_env.sh"

set -o nounset -o errexit

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
                      pytest-pudb sphinx \
                      sphinx_math_dollar sphinx_copybutton furo


if [[ $(mpicc --version) == "IBM XL"* ]]; then
    echo "==== Emirge error: trying to build mpi4py with the XL compiler."
    echo "==== Load a gcc module (e.g. 'ml load gcc' on Lassen)."
    exit 1
fi

python -m pip install --src . -r "$requirements_file"
