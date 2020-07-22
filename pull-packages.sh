#!/bin/bash

set -o nounset -o errexit


if [[ $# -ne 1 || $1 !=  "-x" ]]; then
    echo "WARNING: This script is for advanced users only. It updates the emirge"
    echo "pip packages."
    echo "Execute this script with the '-x' option if you want to run it: '$0 -x'"
    echo "Exiting."
    exit 1
fi



for m in */; do
    # Skip non-git directories
    [[ -d $m/.git/ ]] || continue

    cd $m

    echo "=== Updating $m"

    # Skip directories that have local modifications
    git diff-index --quiet HEAD || { echo "  Skipping update of '$m' due to local modifications."; cd ..; continue; }

    git pull

    cd ..
done

echo "==== Pulled updated modules."
