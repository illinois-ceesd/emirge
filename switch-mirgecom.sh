#!/bin/bash

set -eo pipefail

function usage {
    echo "Usage: $0 <env_name>"
    echo 'Where <env_name> is one of "parlazy", "prod", "prodfusion", "main".'
}


if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

envname="$1"

if [[ "$envname" = "parlazy" ]]; then
    arraycontext=origin/main
    pytato=origin/main
    loopy=kaushikcfd/pytato-array-context-transforms
    meshmode=kaushikcfd/pytato-array-context-transforms
    grudge=origin/main
    mirgecom=origin/distributed-parallel-lazy
elif [[ "$envname" = "prod" ]]; then
    arraycontext=origin/main
    pytato=origin/main
    loopy=kaushikcfd/pytato-array-context-transforms
    meshmode=kaushikcfd/pytato-array-context-transforms
    grudge=origin/main
    mirgecom=origin/production
elif [[ "$envname" = "prodfusion" ]]; then
    arraycontext=kaushikcfd/main
    pytato=kaushikcfd/main
    loopy=kaushikcfd/main
    meshmode=kaushikcfd/main
    grudge=kaushikcfd/main
    mirgecom=origin/fusion_actx

    echo "Installing additional dependencies for prodfusion"
    pip install -U git+https://github.com/pythological/kanren.git#egg=miniKanren
    pip install -U git+https://github.com/kaushikcfd/feinsum.git#egg=feinsum
elif [[ "$envname" = "main" ]]; then
    # Ignore shellcheck warnings regarding unused variables
    # shellcheck disable=SC2034
    arraycontext=origin/main
    # shellcheck disable=SC2034
    pytato=origin/main
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

for pkg in arraycontext pytato loopy meshmode grudge mirgecom; do
    remote_and_branch=${!pkg}
    remote="$(dirname "$remote_and_branch")"
    branch="$(basename "$remote_and_branch")"

    echo "-------------------------------------------------------------------"
    echo "Updating $pkg to $remote_and_branch..."
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
