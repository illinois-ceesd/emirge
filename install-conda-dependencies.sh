#!/bin/bash

set -o nounset -o errexit

echo "==== Installing Conda packages"

conda install --yes pocl numpy pyvisfile pyopencl islpy
