#!/bin/bash

set -o errexit -o nounset

MY_MODULES=$(git submodule status | awk '{print $2}')


# zipfile=$PWD/modules.zip

# rm -f $zipfile

for m in $MY_MODULES; do
    cd $m
    python3 setup.py bdist_wheel
    mv dist/*.whl ..
    cd ..
done
