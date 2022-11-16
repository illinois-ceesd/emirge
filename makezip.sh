#!/bin/bash

set -o errexit -o nounset

origin=$(pwd)
install_loc="${1-$origin}"

zipfile=$install_loc/modules.zip

rm -f "$zipfile"

MY_MODULES=""

for name in */; do
    # Skip non-Python submodules
    if [[ ! -f "$install_loc/$name/setup.py" ]]; then
        echo "Skipping $name since $install_loc/$name/setup.py does not exist."
        continue
    fi

    MY_MODULES+="${name/\//} "

    cd "$install_loc/$name"

    # Feinsum has a different directory scheme
    [[ $name == "feinsum/" ]] && cd src

    echo "=== Zipping $name"
    zip -r "$zipfile" "$name"
    cd "$origin"
done

MY_PYTHON=$(command -v python)

echo "=== Preparing path file of '$MY_PYTHON'"
echo "=== for importing modules from '$zipfile'"
echo

sitepath="$($MY_PYTHON -c 'import site; print(site.getsitepackages()[0])')"
sitefile="$sitepath/emirge.pth"
echo "Found site path: $sitepath"
echo "Attempting to make site file: $sitefile"

echo "$zipfile" > "$sitefile"

echo "=== Done. Make sure to uninstall other copies of the emirge modules:"
echo "=== $MY_PYTHON -m pip uninstall $MY_MODULES"
echo "=== and verify that the correct modules can be loaded by running:"
echo "=== $MY_PYTHON -c 'import dagrt; print(dagrt.__path__)'"
