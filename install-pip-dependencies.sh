#!/bin/bash

set -o nounset -o errexit


MY_MODULES=$(wget -qO- https://github.com/illinois-ceesd/mirgecom/raw/master/requirements.txt)

echo "==== Installing pip packages"

for module in $MY_MODULES; do
    if [[ $module == git+* ]]; then
        module=${module/\#egg=[a-z]*/}

        if [[ $module == *@* ]]; then
            modulebranch="--branch ${module/*@/}"
            module=${module/@*/}
        else
            modulebranch=""
        fi

        moduleurl=${module/git+/}
        modulename=$(basename $module)
        modulename=${modulename/.git/}

        if [[ -d $modulename ]]; then
            echo "Git module $modulename already exists, skipping."
            continue
        fi

        echo "Git module $modulename $moduleurl $modulebranch"

        git clone $modulebranch $moduleurl

        (cd $modulename && pip install -e .)
    else
        echo "Non-git module $module"
        pip install --upgrade $module
    fi
done
