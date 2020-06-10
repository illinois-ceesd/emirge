#!/bin/bash

set -o nounset -o errexit

MY_MODULES=$(git submodule status | awk '{print $2}')

for m in $MY_MODULES; do
    cd $m

    echo $m

    # Skip directories that have local modifications
    git diff-index --quiet HEAD || { echo "  Skipping update of '$m' due to local modifications."; cd ..; continue; }

    git pull origin master

    cd ..
done

echo "==== Pulled updated modules. Maybe you want to commit the submodule changes to emirge?"
