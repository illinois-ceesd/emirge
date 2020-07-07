#!/bin/bash

set -o errexit -o nounset

MY_MODULES=$(git submodule status | awk '{print $2}')

MY_PYTHON=$(command -v python3)


zipfile=$PWD/modules.zip

rm -f "$zipfile"

for m in $MY_MODULES; do
    echo "=== Zipping $m"
    cd "$m"
    zip -r "$zipfile" "$m/"
    cd ..
done


echo "=== Preparing path file of '$MY_PYTHON'"
echo "=== for importing modules from '$zipfile'"
echo

sitefile="$($MY_PYTHON -c 'import site; print(site.getsitepackages()[0])')/emirge.pth"

echo "$zipfile" > "$sitefile"

echo "=== Done. Make sure to uninstall other copies of the emirge modules and"
echo "=== verify that the correct modules can be loaded by running:"
echo "=== $MY_PYTHON -c 'import dagrt; print(dagrt.__path__)'"
