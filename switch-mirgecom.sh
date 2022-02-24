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
    loopy=kaushikcfd/pytato-array-context-transforms
    meshmode=kaushikcfd/pytato-array-context-transforms
    grudge=origin/boundary_lazy_comm_v2
    mirgecom=origin/distributed-parallel-lazy
elif [[ "$envname" = "prod" ]]; then
    loopy=kaushikcfd/pytato-array-context-transforms
    meshmode=kaushikcfd/pytato-array-context-transforms
    grudge=origin/boundary_lazy_comm_v2
    mirgecom=origin/production
elif [[ "$envname" = "main" ]]; then
    # Ignore shellcheck warnings regarding unused variables
    # shellcheck disable=SC2034
    loopy=origin/main
    # shellcheck disable=SC2034
    meshmode=origin/main
    # shellcheck disable=SC2034
    grudge=origin/main
    # shellcheck disable=SC2034
    mirgecom=origin/main
else
    usage
    exit 2
fi

for pkg in loopy meshmode grudge mirgecom; do
    remote_and_branch=${!pkg}
    remote="$(dirname "$remote_and_branch")"
    branch="$(basename "$remote_and_branch")"

    echo "-------------------------------------------------------------------"
    echo "Updating $pkg to $branch..."
    echo "-------------------------------------------------------------------"

    (
    cd "$pkg"

    if [[ $(git remote | grep "$remote") != "$remote" ]]; then
        git remote add "$remote" "git@github.com:$remote/$pkg"
    fi

    git fetch "$remote"

    git checkout "$branch"
    git branch --set-upstream-to="$remote/$branch"
    git pull --rebase "$remote" "$branch"
    )
done

# vim: sw=4
