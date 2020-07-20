#!/bin/bash

set -o errexit -o nounset

usage()
{
  echo "This script uninstalls all conda packages, python modules in conda's python, and conda itself."
  echo
  echo "Usage: $0 [--yes]"
  echo "  --yes             Do not ask for confirmation."
  echo "  --help            Print this help text."
}

# Find conda location
has_conda=$(which conda || true)

if [[ -z $has_conda ]]; then
    echo "Conda not found, exiting."
    exit 1
fi

conda_prefix=$(cd -P "$(dirname $(which conda))/.." && pwd)

# Check that we have a valid dir
if [[ ! -w $conda_prefix ]]; then
    echo "Conda prefix $conda_prefix not writable, exiting."
    exit 2
fi

ans=""


while [[ $# -gt 0 ]]; do
  arg=$1
  shift
  case $arg in
    --yes)
        ans="yes"
        ;;
    --help)
        usage
        exit 0
        ;;
    *)
        usage
        exit 1
        ;;
  esac
done


echo "This script uninstalls all conda packages, python modules in conda's python, and conda itself from:"
echo "  $conda_prefix"

echo "Is this the correct location? (y/N)"

[[ $ans != "yes" ]] && read ans

case $ans in
    y|yes|Yes|YES|Y)
        # Just continue
        ;;
    *)
        echo "Exiting."
        exit 4
        ;;
esac

conda init --reverse

rm -rf "$conda_prefix"
