#!/bin/bash

set -o nounset -o errexit

requirements_file=$1
source ./parse_requirements.sh
parse_requirements ${requirements_file}

echo "==== Installing pip packages"

MY_CONDA_PATH="$(conda info --envs | grep ${MY_CONDA_ENV} | awk '{print $NF}')"
existing_opencl=false
conda_opencl="$(conda list | grep pyopencl | cut -d ' ' -f 1)"
if [ "${conda_opencl}" == "pyopencl" ]; then existing_opencl=true; fi

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
        if [ "${name}" == "pyopencl" ]
        then
            if [ "${existing_opencl}" == false ]
            then
                python -m pip install pybind11 mako
                (cd $name && ./configure.py --cl-inc-dir=$MY_CONDA_PATH/include --cl-lib-dir=$MY_CONDA_PATH/lib --ldflags="" --cl-libname=OpenCL)
                ./install-pip-package ${name}
            else
                printf "Found existing OpenCL in in conda env, skipping installation.\n"
            fi
        else
            ./install-pip-package ${name}
        fi
    fi
done
if [ -f pip_packages.txt ]
then
    printf "Found user-specified conda_packages.txt\n"
    conda_packages="$(cat conda_packages.txt)"
else

