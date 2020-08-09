#!/usr/bin/env bash

set -o errexit -o nounset

origin=$(pwd)
requirements_file="${1-$origin}"
install_loc="${2-$origin}"

if [ ! -f "$requirements_file" ]
then
    echo "makezip.sh::Error: Requirements file ($requirements_file) does not exist."
    exit 1
fi

source ./parse_requirements.sh
parse_requirements "$requirements_file"

zipfile=$install_loc/modules.zip

rm -f "$zipfile"

MY_MODULES=""

for i in "${!module_names[@]}"; do
    name=${module_names[$i]}
    url=${module_urls[$i]}

    # Skip packages that are not git clone'd inside emirge
    [[ -z $url ]] && continue

    # Skip non-Python submodules
    [[ -f "$install_loc/$name/setup.py" ]] || continue

    MY_MODULES+="$name "

    cd "$install_loc/$name"
    echo "=== Zipping $name"
    zip -r "$zipfile" "$name/"
    cd "$origin"
done

MY_PYTHON=$(command -v python3)

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
