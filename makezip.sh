#!/usr/bin/env bash

set -o errexit -o nounset

if [ ! -z "$1" ]
then
    requirements_file=$1
fi
if [ ! -z "$2" ]
then
    install_loc=$2
fi
origin=$(cwd)

if [ -z "$requirements_file" ]
then
    printf "makezip.sh::Error: Requirements file must be specified.\n"
    exit 1
fi

if [ ! -f "$requirements_file" ]
then
    printf "makezip.sh::Error: Requirements file ($requirements_file) does not exist.\n"
    exit 1    
fi

if [ -z "$install_loc" ]
then
    install_loc=$(cwd)
    printf "makezip.sh::Warning: No install location given, defaulting to ($install_loc).\n"
fi

source ./parse_requirements.sh
parse_requirements $requirements_file

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
    cd $origin
done

MY_PYTHON=$(command -v python3)

echo "=== Preparing path file of '$MY_PYTHON'"
echo "=== for importing modules from '$zipfile'"
echo

sitepath="$($MY_PYTHON -c 'import site; print(site.getsitepackages()[0])')"
sitefile="$sitepath/emirge.pth"
printf "Found site path: ${sitepath}\n"
printf "Attempting to make site file: ${sitefile}\n"

echo "$zipfile" > "$sitefile"

echo "=== Done. Make sure to uninstall other copies of the emirge modules:"
echo "=== $MY_PYTHON -m pip uninstall $MY_MODULES"
echo "=== and verify that the correct modules can be loaded by running:"
echo "=== $MY_PYTHON -c 'import dagrt; print(dagrt.__path__)'"
