#!/bin/bash

set -o nounset -o errexit

echo "==== Installing Conda packages for $(which conda)"

conda info --envs

conda install --yes git pip pocl pyvisfile islpy pyopencl xmltodict fparser matplotlib pep8 flake8
