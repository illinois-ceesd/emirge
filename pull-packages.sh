#!/bin/bash

set -o nounset -o errexit

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


if [[ $# -ne 1 || $1 !=  "-x" ]]; then
    echo "WARNING: This script is for advanced users only. It updates the emirge"
    echo "pip, conda, and development (git) packages."
    echo "Execute this script with the '-x' option if you want to run it: '$0 -x'"
    echo "Exiting."
    exit 1
fi

echo "==== Pulling git packages."

for m in */; do
    # Skip non-git directories
    [[ -d $m/.git/ ]] || continue

    cd "$m" || exit 2

    echo "=== Updating $m"

    # Skip directories that have local modifications
    git diff-index --quiet HEAD || { echo "  Skipping update of '$m' due to local modifications."; cd ..; continue; }

    # Skip directories that are not on branches (can't use 'git pull' in that case)
    if [[ $(git rev-parse --abbrev-ref --symbolic-full-name HEAD) == "HEAD" ]]; then
        echo "  Skipping update of '$m' since it is not on a branch."
        cd ..
        continue
    fi


    git pull

    cd ..
done


echo "==== Updating conda packages."

if [[ $(command -v conda) ]] && [[ -f $SCRIPT_DIR/config/activate_env.sh ]]; then
    set +o nounset

    # Workaround for https://github.com/illinois-ceesd/emirge/issues/101
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/config/activate_env.sh"

    conda update --all -n base --yes
    conda update --all --yes

    set -o nounset
else
    echo "==== Conda not found, not updating conda packages."
fi


echo "==== Updating pip packages."

# Note that 'conda list' and 'pip list' generally contain both
# conda-installed and pip-installed packages, so we need to do some
# filtering to make sure we don't override conda packages with newer
# pip packages.

# Packages conda thinks were installed via pip/pypi
conda_pypi=$(conda list | awk '/pypi/ {print $1}')

# Names of outdated packages according to pip
pip_outdated=$(pip list --local --outdated | tail +3 | awk '{print $1}')

# For each outdated package, make sure it was actually installed by pip
# before updating it.
for p in $pip_outdated; do
    for pp in $conda_pypi; do
        if [[ $p == "$pp" ]]; then
            echo "=== Updating $p"
            pip install --upgrade "$p"
        fi
    done
done

echo "==== Done."
