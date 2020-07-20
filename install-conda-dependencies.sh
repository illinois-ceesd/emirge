#!/bin/bash

set -o nounset -o errexit

echo "==== Installing Conda packages for $(which conda)"

conda info --envs

conda install --yes pocl numpy pyvisfile
