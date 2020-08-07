#!/bin/bash

packagepath=$1
if [[ -z "$packagepath" ]]
then
    echo "Error: No package path given."
fi
# See https://github.com/illinois-ceesd/mirgecom/pull/43 for why this is not 'pip install -e .'
(cd $packagepath && python setup.py develop)
