#!/bin/bash

set -o errexit
# Conda does not like 'set -o nounset'

echo "#####################################################"
echo "# This script installs the dependencies for emirge. #"
echo "#####################################################"
echo

usage()
{
    echo "Usage: $0 [--install-prefix=DIR] [--conda-prefix=DIR] [--env-path=DIR]"
    echo "                    [--env-name=NAME] [--modules] [--help]"
    echo 
    echo "  --install-prefix=DIR  Path to install mirgecom in (default=./)."
    echo "  --config-path=DIR     Path to look for package lists and other config."
    echo "  --conda-prefix=DIR    Install conda in non-default prefix."
    echo "  --env-path=DIR        Install environment in non-default place."
    echo "  --env-name=DIR        Install conda environment with custom name."
    echo "  --modules             Create modules.zip and add to Python path."
    echo "  --help                Print this help text."
}

# Default conda location
system_conda=`which conda`
conda_prefix=$HOME/miniforge3
env_name="dgfem"
env_path=""
env_path_spec="no"
env_name_spec="no"
# Build modules.zip? (via makezip.sh)
opt_modules=0
install_path="./"
config_path="./"

while [[ $# -gt 0 ]]; do
    arg=$1
    shift
    case $arg in
        --install-prefix=*)
            # Install mirgecom in non-default prefix
            install_path=${arg#*=}
            ;;
        --config-path=*)
            # Look for package lists here
            config_path=${arg#*=}
            ;;
        --conda-prefix=*)
            # Install conda in non-default prefix
            conda_prefix=${arg#*=}
            ;;
        --env-path=*)
            # Install conda in non-default prefix
            env_path=${arg#*=}
            env_path_spec="yes"
            ;;
        --env-name=*)
            # Install conda in non-default prefix
            env_name=${arg#*=}
            env_name_spec="yes"
            ;;
        --modules)
            # Create modules.zip
            opt_modules=1
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

if [ "${env_name_spec}" == "yes" ] && [ "${env_path_spec}"  == "yes" ]
then
    printf "Cannot specify both --env-name and --env-path simultaneously\n"
    exit 1
fi

# Conda does not like ~
conda_prefix=$(echo $conda_prefix | sed s,~,$HOME,)
if [ ! -z "${env_path}" ]
then
    env_path=$(echo $env_path | sed s,~,$HOME,)
    printf "Overriding conda env name (${env_name}) with user-specified path (${env_path}).\n"
fi

# ====== Install, create, activate conda section =====

# If a system version of conda is found, use it by default
# Subvert this check using `yes`.
install_conda="yes"
if [ ! -z ${system_conda} ]
then
    install_conda="no"
    printf "Found system conda (${system_conda}), do you want to install a new one? (y/N): "
    read yesno
    if [ "${yesno}" == "" ]; then yesno="no"; fi
    yesno="$(echo ${yesno^} | head -c 1)"
    if [ "${yesno}" == "Y" ]; then install_conda="yes"; fi
    printf "${yesno}\n"
fi


# Install conda if directed or necessary
if [ "${install_conda}" == "yes" ]
then
    export MY_CONDA_DIR=$conda_prefix
    printf "Installing conda in: ${MY_CONDA_DIR}\n"
    ./install-conda.sh
    export PATH=$MY_CONDA_DIR/bin:$PATH
fi

create_environment="yes"
existing_env=""
if [ ! -z "${env_path}" ]
then
    existing_env="$(conda info --envs | grep ${env_path} | awk '{print $NF}')"
else
    existing_env="$(conda info --envs | cut -d ' ' -f 1 | grep ${env_name})"
    if [ "${existing_env}" != "${env_name}" ]; then existing_env=""; fi
fi
if [ ! -z "${existing_env}" ]
then
    printf "Found existing conda environment (${existing_env}), skipping env creation.\n"
    create_environment="no"
    export MY_CONDA_ENV=${existing_env}
else
    printf "Found no existing environments matching "
    if [ ! -z "${env_path}" ]
    then
        printf "path (${env_path}).\n"
        MY_CONDA_ENV=${env_path}
    else
        printf "name (${env_name}).\n"
        MY_CONDA_ENV=${env_name}
    fi
fi

# Create and/or activate the environment if directed or necessary
if [ "${create_environment}" == "yes" ]
then
    printf "==== Creating conda environment\n"
    if [ ! -z "${env_path}" ]
    then
        printf "Creating conda env at path: (${env_path}).\n"
        conda create -p ${env_path} --yes
        env_name=${env_path}
        export MY_CONDA_ENV=${env_name}
    else
        printf "Creating conda env with name: (${env_name}).\n"
        conda create --name ${env_name} --yes
        export MY_CONDA_ENV=${env_name}
    fi
    # suspect 'conda activate ${env_name}' must fail some places? 
    #    source $MY_CONDA_DIR/bin/activate dgfem
    conda activate ${env_name}
else
    # Activate (if necessary)
    active_env="$(conda info --envs | grep '*' | cut -d ' ' -f 1)"
    if [ -z "${active_env}" ]
    then
        active_env="$(conda info --envs | grep '*' | awk '{print $NF}')"
    fi
    if [ "${active_env}" != "${MY_CONDA_ENV}" ]
    then
        printf "If conda activation fails, activate manually with:\n"
        printf "> conda activate ${MY_CONDA_ENV}\n"
        printf "Then restart the (install.sh) script to continue.\n"
        printf "Attempting to activate conda env(${MY_CONDA_ENV})\n"
        conda activate ${MY_CONDA_ENV}
    else
        printf "Conda env(${active_env}) already activated.\n"
    fi
fi
# ^^^^^^^^^^ Install, create, activate conda environment(s) ^^^^^^^^^
# After this point we assume conda and its environment are all set up
if [ ! -d ${install_path}/config ]; then mkdir -p ${install_path}/config; fi
if [ -d ${config_path} ]; then cp -r ${config_path}/* ${install_path}/config; fi
rm -rf ${install_path}/config/conda_env_name
printf "${MY_CONDA_ENV}" > ${install_path}/config/conda_env_name
./install-conda-packages ${config_path}
./install-pip-packages ${install_path} ./pip_packages.txt
./fetch-mirgecom ${install_path}
./install-pip-packages ${install_path} ${install_path}/mirgecom/requirements.txt
./install-pip-package ${install_path}/mirgecom

# TODO: makezip.sh still needs ported!
[[ $opt_modules -eq 1 ]] && ./makezip.sh

echo
echo "==================================================================="
echo "Emirge has installed mirgecom in ${install_path}."
echo "Before using, make sure to activate the conda environment:"
echo " $ conda activate ${MY_CONDA_ENV}"
echo "To test mirgecom: "
echo " $ cd ${install_path}/test"
echo " $ pytest *.py"
echo "To run mirgecom examples:"
echo " $ cd ${install_path}"
echo " $ mkdir run_examples"
echo " $ cd run_examples"
echo " $ ../examples/run_examples.sh ../examples"
echo "==================================================================="
