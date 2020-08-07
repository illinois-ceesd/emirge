#!/bin/bash

set -o nounset -o errexit

requirements_file=$1
install_location=$2

if [ -z "$install_location" ]
then
    install_location=`pwd`
fi
if [ ! -d "$install_location" ]
then
    mkdir -p $install_location
fi
source ./parse_requirements.sh

parse_requirements $requirements_file

echo "==== Installing pip packages"

# Semi-required for pyopencl
python -m pip install mako
# Some nice-to haves for development
python -m pip install pytest pudb flake8 pep8-naming pytest-pudb sphinx

# Get the *active* env path
MY_CONDA_PATH="$(conda info --envs | grep '*' | awk '{print $NF}')"

origin=`pwd`
for i in "${!module_names[@]}"; do
    name=${module_names[$i]}
    branch=${module_branches[$i]}
    url=${module_urls[$i]}

    if [[ -z $url ]]; then
        echo "=== Installing non-git module $name"
        pip install --upgrade $name
    else
        echo "=== Installing git module $name $url ${branch/--branch /}"
        if [ ! -d "$install_location/$name" ]
        then
            cd $install_location && git clone --recursive $branch $url $name 
        else
            cd $install_location/$name && git checkout $branch && git pull
        fi
        [[ $name == "pyopencl" || $name == "islpy" ]] && continue
        cd $origin
        # See https://github.com/illinois-ceesd/mirgecom/pull/43 for why this is not 'pip install -e .'
        ./install-src-package.sh $install_location/$name
    fi
done
unset module_names
unset module_urls
unset module_branches

