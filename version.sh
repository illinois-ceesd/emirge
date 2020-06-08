#!/bin/bash

set -o nounset -o errexit


echo "*** Pip info"

echo -n "Pip path: "
which pip && pip freeze || echo "No pip found."


echo "*** Conda info"

echo -n "Conda path: "
which conda && conda info || echo "No conda found." 


echo "*** Emirge modules"

function print_git_status {
	res=""

	# Modified/untracked files?
	[[ -n $(git status -s) ]] && res+="*"

	res+="$(basename $PWD)|"
	
	res+="$(git log -1 --pretty --oneline)|"
	res+="$(git log -1 --format=%cd --date=format:"%Y-%m-%d %H:%M")\n"
	echo $res
}


MY_MODULES=$(git submodule status | awk '{print $2}' | tr '\n' ' ')

text="Package|Commit|Date\n"
text+="=======|======|====\n"

for m in $MY_MODULES; do
	cd $m

	text+=$(print_git_status)
	
	cd ..
done

# Emirge status
text+=$(print_git_status)

echo -e $text | column -t -s '|'