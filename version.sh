#!/bin/bash

set -o nounset -o errexit


echo "*** Pip info"

python3 -m pip freeze


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

function print_git_status {
    res=""

    # Modified/untracked files?
    [[ -n $(git status -s) ]] && res+="*"

    # Package name
    res+="$(basename $PWD)|"

    # Branch name
    res+="$(git describe --all --always| sed s,^heads/,, | sed s,remotes/origin/,,)|"

    # Commit message
    res+="$(git log -1 --pretty --oneline)|"

    # Date
    res+="$(git log -1 --format=%cd --date=format:"%Y-%m-%d %H:%M")\n"
    echo $res
}


MY_MODULES=$(git submodule status | awk '{print $2}')

text="Package|Branch|Commit|Date\n"
text+="=======|======|======|====\n"

for m in $MY_MODULES; do
    cd $m

    text+=$(print_git_status)

    cd ..
done

# Emirge status
text+=$(print_git_status)

echo -e $text | column -t -s '|'