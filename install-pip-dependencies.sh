#!/bin/bash

set -o nounset -o errexit


source ./parse_requirements.sh

parse_requirements

echo "==== Installing pip packages"

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
        (cd $name && pip install -e .)
    fi
done
