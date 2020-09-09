#!/bin/bash

set -o nounset -o errexit

requirements_file=${1-mirgecom/requirements.txt}

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

which lsb_release >/dev/null && lsb_release -ds
which sw_vers >/dev/null && echo "MacOS $(sw_vers -productVersion)"
uname -a


echo
echo "*** Emirge modules"

source ./parse_requirements.sh

parse_requirements "$requirements_file"

res="Package|Branch|Commit|URL\n"
res+="=======|======|======|======\n"

for i in "${!module_names[@]}"; do

    name=${module_names[$i]}
    branch=${module_branches[$i]/--branch /}
    url=${module_urls[$i]}

    if [[ -d $name ]]; then
        commit=$(cd "$name" && git describe --always)
    else
        commit="---"
    fi

    branch=${branch:----}
    url=${url:----}

    res+="$name|$branch|$commit|$url\n"
done

echo -e "$res" | column -t -s '|'
