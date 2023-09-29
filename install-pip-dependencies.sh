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

switch_requirements_to_ssh() {
  input_file="$1"
  output_file="$2"

  # Read the input file
  while IFS= read -r line; do
    # Check if the line starts with "git+https://github"
    if [[ $line == *editable\ git+https://github* ]]; then
      # Replace "git+https://github" with "git+ssh://git@github"
      modified_line=${line//git+https:\/\/github/git+ssh:\/\/git@github}
      echo "$modified_line"
    else
      echo "$line"
    fi
  done < "$input_file" > "$output_file"
}



switch_requirements_to_ssh $requirements_file ssh_requirements.txt
export MPI4PY_BUILD_CONFIGURE=1
# Install the packages from the new requirements file
pip install --src . -r ssh_requirements.txt
