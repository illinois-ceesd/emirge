#!/bin/bash

set -eo pipefail


if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <env_name>"
    echo 'Where <env_name> is one of "parlazy", "prod", "main".'
    exit 1
fi

envname="$1"
if [[ "$envname" = "parlazy" ]]; then
    declare -A PACKAGE_TO_REMOTE_AND_BRANCH=( \
        [loopy]=kaushikcfd/pytato-array-context-transforms
        [meshmode]=kaushikcfd/pytato-array-context-transforms
        [arraycontext]=kaushikcfd/pytato-array-context-transforms
        [grudge]=github/boundary_lazy_comm_v2
        [mirgecom]=github/distributed-parallel-lazy
    )
elif [[ "$envname" = "prod" ]]; then
    declare -A PACKAGE_TO_REMOTE_AND_BRANCH=( \
        [loopy]=kaushikcfd/pytato-array-context-transforms
        [meshmode]=kaushikcfd/pytato-array-context-transforms
        [arraycontext]=kaushikcfd/pytato-array-context-transforms
        [grudge]=github/boundary_lazy_comm_v2
        [mirgecom]=github/production
    )
elif [[ "$envname" = "main" ]]; then
    declare -A PACKAGE_TO_REMOTE_AND_BRANCH=( \
        [loopy]=github/main
        [arraycontext]=github/main
        [meshmode]=github/main
        [grudge]=github/main
        [mirgecom]=github/main
    )
else
    echo "usage: $0 envname (must be one of a few known ones)"
fi

for pkg in "${!PACKAGE_TO_REMOTE_AND_BRANCH[@]}"; do
    remote_and_branch="${PACKAGE_TO_REMOTE_AND_BRANCH[$pkg]}"
    remote="$(dirname "$remote_and_branch")"
    branch="$(basename "$remote_and_branch")"

    echo "-------------------------------------------------------------------"
    echo "Updating $pkg to $branch..."
    echo "-------------------------------------------------------------------"

		(
    cd "$pkg"
    git fetch "$remote"

    git checkout "$branch"
    git branch --set-upstream-to="$remote/$branch"
    git pull --rebase "$remote" "$branch"
		)
done

# vim: sw=4
