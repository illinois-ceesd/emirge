#!/bin/bash

set -o nounset -o errexit

MY_MODULES="dagrt leap loopy meshmode grudge mirgecom"

for m in $MY_MODULES; do
    if [[ ! -f $m/setup.py ]]; then
        echo "==== ERROR: incomplete git clone. Please run:"
        echo "====   git submodule init && git submodule update"
        echo "==== to fetch emirge's submodules."
        exit 1
    fi
done

echo "==== Installing pip packages"

for module in $MY_MODULES; do
    (cd $module && pip install -e .)
done
