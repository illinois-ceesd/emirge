#!/bin/bash

set -o nounset -o errexit


source ./parse_requirements.sh

parse_requirements

echo "==== Installing pip packages"

# Semi-required for pyopencl
python -m pip install mako

# Semi-required for meshpy source install, avoids warning and wait
python -m pip install pybind11

# Some nice-to haves for development
python -m pip install pytest pudb flake8 pep8-naming pytest-pudb sphinx

# MY_CONDA_PATH="$(conda info --envs | grep dgfem | awk '{print $3}')"


for i in "${!module_names[@]}"; do
    name=${module_names[$i]}
    branch=${module_branches[$i]}
    url=${module_urls[$i]}

    if [[ -z $url ]]; then
        echo "=== Installing non-git module $name with pip"
        python -m pip install --upgrade "$name"
    else
        echo "=== Installing git module $name $url ${branch/--branch /}"
        #shellcheck disable=SC2086
        [[ ! -d $name ]] && git clone --recursive $branch "$url"

        [[ $name == "pyopencl" || $name == "islpy" ]] && continue

        # See https://github.com/illinois-ceesd/mirgecom/pull/43 for why this is not 'pip install -e .'
        if [[ $name == "f2py" ]]; then
                # f2py/fparser doesn't use setuptools, so 'develop' isn't a thing
                (cd "$name" && python setup.py install)
        else
                (cd "$name" && python setup.py develop)
        fi
    fi
done

# See https://github.com/illinois-ceesd/mirgecom/pull/43 for why this is not 'pip install -e .'
(cd mirgecom && python setup.py develop)
