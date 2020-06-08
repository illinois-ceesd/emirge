#!/bin/bash

set -o nounset -o errexit

MY_MODULES=$(git submodule status | awk '{print $2}')

for m in $MY_MODULES; do
    cd $m

    echo $m

    git pull

    cd ..
done

echo "Pulled updated modules. Now commit the changes."
