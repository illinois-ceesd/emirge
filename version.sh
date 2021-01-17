#!/bin/bash

set -o nounset -o errexit

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "$SCRIPT_DIR"

usage()
{
  echo "Usage: $0 [--requirements-file=FILE] [--output-requirements=FILE] [--output-conda-env=FILE] [--help]"
  echo "  --requirements-file=FILE    Use specific requirements.txt file (default=mirgecom/requirements.txt)."
  echo "  --output-requirements=FILE  Write pip requirements file to FILE (instead of stdout)."
  echo "  --output-conda-env=FILE     Write conda environment file to FILE (instead of stdout)."
  echo "  --help                      Print this help text."
}

requirements_file="mirgecom/requirements.txt"
output_requirements=""
output_conda_env=""

while [[ $# -gt 0 ]]; do
  arg=$1
  shift
  case $arg in
    --requirements-file=*)
        # Use non-default requirements.txt file
        requirements_file=${arg#*=}
        ;;
    --output-requirements=*)
        # Output requirements.txt file with this file name
        output_requirements=${arg#*=}
        ;;
    --output-conda-env=*)
        # Output conda env file with this file name
        output_conda_env=${arg#*=}
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

if [[ ! -f "$requirements_file" ]]
then
    echo "version.sh::Error: Requirements file ($requirements_file) does not exist."
fi

echo "*** Pip info"

python -m pip freeze


echo
echo "*** Conda info"

echo -n "Conda path: "
which conda || echo "No conda found."

conda info

conda info --envs

conda list


echo
echo "*** OS info"

which lsb_release >/dev/null 2>/dev/null && lsb_release -ds
which sw_vers >/dev/null 2>/dev/null && echo "MacOS $(sw_vers -productVersion)"
uname -a


echo
echo "*** Emirge modules"

source ./parse_requirements.sh

parse_requirements "$requirements_file"

res="Package|Branch|Commit|Date|URL\n"
res+="=======|======|======|======|======\n"

for i in "${!module_names[@]}"; do

    name=${module_names[$i]}
    branch=${module_branches[$i]/--branch /}
    url=${module_urls[$i]}

    if [[ -d $name ]]; then
        cd "$name" || exit 1
        commit=$(git describe --always --dirty=*)
        date="$(git show -s --format=%cd --date=short HEAD) ($(git show -s --format=%cd --date=relative HEAD))"
        branchname_git="($(git rev-parse --abbrev-ref HEAD))"
        cd ..
    elif [[ $name == "loopy" && -d loo-py ]]; then
        # FIXME: this is a hack that was needed before loo-py was renamed to loopy;
        # remove this by 12/2021.
        # https://github.com/illinois-ceesd/emirge/pull/85
        cd loo-py || exit 1
        commit=$(git describe --always --dirty=*)
        date="$(git show -s --format=%cd --date=short HEAD) ($(git show -s --format=%cd --date=relative HEAD))"
        branchname_git="($(git rev-parse --abbrev-ref HEAD))"
        cd ..
    else
        date="---"
        commit="---"
        branchname_git="---"
    fi

    branch=${branch:-$branchname_git}
    url=${url:----}

    res+="$name|$branch|$commit|$date|$url\n"
done

echo -e "$res" | column -t -s '|'

echo
echo "*** Requirements file with current emirge module versions"


echo "# requirements.txt created by version.sh" | tee $output_requirements
#shellcheck disable=SC2129
echo "# Date: $(date)" | tee -a $output_requirements
echo "# Host: $(hostname -f) [$(uname -a)]" | tee -a $output_requirements
echo "# Python: $(which python) [$(python --version)]" | tee -a $output_requirements

seen_mirgecom=0

for i in "${!module_names[@]}"; do
    url=${module_full_urls[$i]}
    name=${module_names[$i]}
    branch=${module_branches[$i]/--branch /}
    giturl=${url/\#egg=[a-z]*/}
    [[ ${url} =~ (#egg=[a-z]*) ]] && egg=${BASH_REMATCH[1]} || egg=""
    [[ -z $url ]] && continue # Ignore non-Git modules

    if [[ $name == "f2py" ]]; then
        # Can't install f2py this way
        continue
    elif [[ -d $name ]]; then
        commit=$(cd "$name" && git describe --always)
    elif [[ $name == "loopy" && -d loo-py ]]; then
        commit=$(cd loo-py && git describe --always)
    else
        echo "Warning: missing module '$name'. Skipping."
        continue
    fi

    [[ $name == "mirgecom" ]] && seen_mirgecom=1

    if [[ -n $branch ]]; then
        url_new_branch=${giturl/$branch/$commit}
    else
        url_new_branch="${giturl}@${commit}"
    fi

    echo "--editable $url_new_branch$egg" | tee -a $output_requirements
done

# Record mirgecom version as well, if it is not part of the requirements.txt
if [[ $seen_mirgecom -eq 0 ]]; then
    commit=$(cd mirgecom && git describe --always)
    echo "--editable git+https://github.com/illinois-ceesd/mirgecom@$commit#egg=mirgecom" | tee -a $output_requirements
fi

# If output is a file (ie, not stdout), print the file and tell user how to install it
if [[ -f "$output_requirements" ]]; then
    echo "*** Created file '$output_requirements'. Install it with 'pip install --src . -r $output_requirements'."
fi


echo
echo "*** Conda env file with current conda package versions"

# remove f2py since it can' t be pip install'ed
conda env export | grep -v f2py | tee $output_conda_env

# If output is a file (ie, not stdout), print the file and tell user how to install it
if [[ -f "$output_conda_env" ]]; then
    echo "*** Created file '$output_conda_env'. Install it with 'conda env create -f=$output_conda_env'"
fi
