#!/bin/bash


declare -a module_names
declare -a module_urls
declare -a module_branches
declare -a module_full_urls

parse_requirements() {
    requirements_file=$1
    [[ -z "$requirements_file" ]] && echo "Error: No requirements file specified."
    [[ ! -f "$requirements_file" ]] && echo "Error: Requirements file ($requirements_file) does not exist."
    local MY_MODULES
    MY_MODULES=$(grep -E -v '^[[:space:]]*#' "$requirements_file")

    for module in $MY_MODULES; do

        if [[ $module == "--editable" ]]; then
            # Ignore the 'editable' keyword
            continue
        elif [[ $module == git+* ]]; then
            local fullurl=$module
            local module=${module/\#egg=[a-z]*/}

            if [[ $module == *@* ]]; then
                local modulebranch="--branch ${module/*@/}"
                local module=${module/@*/}
            else
                local modulebranch=""
            fi

            local moduleurl=${module/git+/}
            local modulename
            modulename=$(basename "$module")
            local modulename=${modulename/.git/}

            module_names+=("$modulename")
            module_urls+=("$moduleurl")
            module_full_urls+=("$fullurl")
            module_branches+=("$modulebranch")
        else
            module_names+=("$module")
            module_urls+=("")
            module_full_urls+=("")
            module_branches+=("")
        fi
    done
}
