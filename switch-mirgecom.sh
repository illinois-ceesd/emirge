#!/bin/bash

set -eo pipefail

function usage {
    echo "Usage: $0 <env_name>"
    echo 'Where <env_name> is one of "parlazy", "prod", "main".'
}


if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

envname="$1"

if [[ "$envname" = "parlazy" ]]; then
    LOOPY=kaushikcfd/pytato-array-context-transforms
    MESHMODE=kaushikcfd/pytato-array-context-transforms
    GRUDGE=origin/boundary_lazy_comm_v2
    MIRGECOM=origin/distributed-parallel-lazy
elif [[ "$envname" = "prod" ]]; then
    LOOPY=kaushikcfd/pytato-array-context-transforms
    MESHMODE=kaushikcfd/pytato-array-context-transforms
    GRUDGE=origin/boundary_lazy_comm_v2
    MIRGECOM=origin/production
elif [[ "$envname" = "main" ]]; then
    LOOPY=origin/main
    MESHMODE=origin/main
    GRUDGE=origin/main
    MIRGECOM=origin/main
else
    usage
    exit 2
fi

for pkg in LOOPY MESHMODE GRUDGE MIRGECOM; do
    pkg_lower=$(echo "$pkg" | tr '[:upper:]' '[:lower:]')
    remote_and_branch=${!pkg}
    remote="$(dirname "$remote_and_branch")"
    branch="$(basename "$remote_and_branch")"

    echo "-------------------------------------------------------------------"
    echo "Updating $pkg_lower to $branch..."
    echo "-------------------------------------------------------------------"

    (
    cd "$pkg_lower"

    if [[ $(git remote | grep "$remote") != "$remote" ]]; then
        git remote add "$remote" "git@github.com:$remote/$pkg_lower"
    fi

    git fetch "$remote"

    git checkout "$branch"
    git branch --set-upstream-to="$remote/$branch"
    git pull --rebase "$remote" "$branch"
    )
done

# vim: sw=4
