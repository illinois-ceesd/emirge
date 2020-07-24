#!/bin/bash

set -o nounset -o errexit


source ./parse_requirements.sh

parse_requirements

echo "==== Installing pip packages"

# Required for pyopencl
python -m pip install pybind11 mako
[ -z "${CEESD_CONDA_KEY}" ] && CEESD_CONDA_KEY="dgfem"
MY_CONDA_PATH="$(conda info --envs | grep ${CEESD_CONDA_KEY} | awk '{print $NF}')"
printf "Using Conda Environment Path: ${MY_CONDA_PATH}\n"

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

        [[ $name == "pyopencl" ]] && (cd $name && ./configure.py --cl-inc-dir=$MY_CONDA_PATH/include --cl-lib-dir=$MY_CONDA_PATH/lib --ldflags="" --cl-libname=OpenCL)

        (cd $name && pip install -v -e .)
    fi
done

(cd mirgecom && pip install -v -e .)
