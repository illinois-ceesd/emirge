#!/bin/bash

set -o nounset -o errexit


source ./parse_requirements.sh

parse_requirements

echo "==== Installing pip packages"

# Semi-required for pyopencl
python -m pip install mako

# Some nice-to haves for development
python -m pip install pytest pudb flake8 pep8-naming pytest-pudb sphinx

MY_CONDA_PATH="$(conda info --envs | grep dgfem | awk '{print $3}')"


for i in "${!module_names[@]}"; do
    name=${module_names[$i]}
    branch=${module_branches[$i]}
    url=${module_urls[$i]}

    if [[ -z $url ]]; then
        echo "=== Installing non-git module $name"
        pip install --upgrade $name
    else
        echo "=== Installing git module $name $url ${branch/--branch /}"
        [[ ! -d $name ]] && git clone --recursive $branch $url

        [[ $name == "pyopencl" || $name == "islpy" ]] && continue

        # See https://github.com/illinois-ceesd/mirgecom/pull/43 for why this is not 'pip install -e .'
        (cd $name && python setup.py develop)
    fi
done

# See https://github.com/illinois-ceesd/mirgecom/pull/43 for why this is not 'pip install -e .'
(cd mirgecom && python setup.py develop)
