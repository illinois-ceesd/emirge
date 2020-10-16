#!/bin/bash

set -o nounset -o errexit

requirements_file=${1-mirgecom/requirements.txt}

if [[ ! -f "$requirements_file" ]]
then
    echo "version.sh::Error: Requirements file ($requirements_file) does not exist."
fi

echo "*** Pip info"

python -m pip freeze


echo
echo "*** Conda info"

echo -n "Conda path: "
which conda || echo "No conda found."

conda info

conda info --envs

conda list


echo
echo "*** OS info"

which lsb_release >/dev/null && lsb_release -ds
which sw_vers >/dev/null && echo "MacOS $(sw_vers -productVersion)"
uname -a


echo
echo "*** Emirge modules"

source ./parse_requirements.sh

parse_requirements "$requirements_file"

res="Package|Branch|Commit|Date|URL\n"
res+="=======|======|======|======|======\n"

for i in "${!module_names[@]}"; do

    name=${module_names[$i]}
    branch=${module_branches[$i]/--branch /}
    url=${module_urls[$i]}

    if [[ -d $name ]]; then
        cd "$name" || exit 1
        commit=$(git describe --always --dirty=*)
        date="$(git show -s --format=%cd --date=short HEAD) ($(git show -s --format=%cd --date=relative HEAD))"
        branchname_git="($(git rev-parse --abbrev-ref HEAD))"
        cd ..
    elif [[ $name == "loopy" && -d loo-py ]]; then
        cd loo-py || exit 1
        commit=$(git describe --always --dirty=*)
        date="$(git show -s --format=%cd --date=short HEAD) ($(git show -s --format=%cd --date=relative HEAD))"
        branchname_git="($(git rev-parse --abbrev-ref HEAD))"
        cd ..
    else
        date="---"
        commit="---"
        branchname_git="---"
    fi

    branch=${branch:-$branchname_git}
    url=${url:----}

    res+="$name|$branch|$commit|$date|$url\n"
done

echo -e "$res" | column -t -s '|'

echo
echo "*** Creating requirements file with current emirge module versions"


outfile=$(mktemp requirements.txt.XXXXXX)

echo "# requirements.txt created by version.sh" > "$outfile"
echo "# Date: $(date)" >> "$outfile"

for i in "${!module_names[@]}"; do
    url=${module_full_urls[$i]}
    name=${module_names[$i]}
    branch=${module_branches[$i]/--branch /}
    giturl=${url/\#egg=[a-z]*/}
    [[ ${url} =~ (#egg=[a-z]*) ]] && egg=${BASH_REMATCH[1]} || egg=""
    [[ -z $url ]] && continue # Ignore non-Git modules

    if [[ -d $name ]]; then
        commit=$(cd "$name" && git describe --always)
    elif [[ $name == "loopy" && -d loo-py ]]; then
        commit=$(cd loo-py && git describe --always)
    else
        echo "Warning: missing module '$name'. Skipping."
        continue
    fi

    if [[ -n $branch ]]; then
        url_new_branch=${giturl/$branch/$commit}
    else
        url_new_branch="${giturl}@${commit}"
    fi

    echo "$url_new_branch$egg" | tee -a "$outfile"
done

echo "**Created file '$outfile'. Install it with 'pip install -r $outfile'."
