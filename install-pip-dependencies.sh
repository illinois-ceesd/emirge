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
source ./parse_requirements.sh

parse_requirements "$requirements_file"

echo "==== Installing pip packages from $requirements_file"

# Semi-required for pyopencl
python -m pip install mako

# Semi-required for meshpy source install, avoids warning and wait
python -m pip install pybind11

# Some nice-to haves for development
python -m pip install pytest pudb flake8 pep8-naming flake8-quotes pytest-pudb sphinx \
                      sphinx_math_dollar sphinx_copybutton furo


if [[ $(mpicc --version) == "IBM XL"* ]]; then
    echo "==== Emirge error: trying to build mpi4py with the XL compiler."
    echo "==== Load a gcc module (e.g. 'ml load gcc' on Lassen)."
    exit 1
fi

# Get the *active* env path
#MY_CONDA_PATH="$(conda info --envs | grep '*' | awk '{print $NF}')"

origin=$(pwd)
for i in "${!module_names[@]}"; do
    name=${module_names[$i]}
    branch=${module_branches[$i]/--branch /}
    url=${module_urls[$i]}

    if [[ $name == "pyopencl" || $name == "islpy" || $name == "pymetis" ]]; then
        echo "==== Skipping '$name' as it is installed via conda"
        continue
    fi

    if [[ -z $url ]]; then
        echo "=== Installing non-git module $name with pip"
        # Remove the cached version of the package so we are not installing stale packages.
        # See https://github.com/illinois-ceesd/emirge/pull/94 for an explanation
        if [[ $(pip cache list "$name") != "Nothing cached." ]]; then
            echo "==== Removing '$name' from pip cache"
            python -m pip cache remove "$name"
        fi

        python -m pip install --upgrade "$name"
    else
        echo "=== Installing git module $name $url $branch"

        if [[ ! -d "$install_location/$name" ]]
        then
            cd "$install_location"
            git clone --recursive "$url" "$name"
            [[ -n $branch ]] && git checkout "$branch"
        else
            cd "$install_location/$name"
            [[ -n $branch ]] && git checkout "$branch"
        fi

        cd "$origin"

        install_mode="develop"

        if [[ $name == "f2py" ]]; then
            # f2py/fparser doesn't use setuptools, so 'develop' isn't a thing
            install_mode="install"
        fi

        ./install-src-package.sh "$install_location/$name" "$install_mode"
    fi
done
unset module_names
unset module_urls
unset module_branches
