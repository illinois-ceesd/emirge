#!/bin/bash

packagepath=$1
if [ -z "$packagepath" ]
then
    printf "Error: No package path given.\n"
fi
# See https://github.com/illinois-ceesd/mirgecom/pull/43 for why this is not 'pip install -e .'
(cd $packagepath && python setup.py develop)

