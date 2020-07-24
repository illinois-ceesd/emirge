
mcmodule=$(cat ./requirements.txt)
if [[ $mcmodule == *@* ]]; then
    mcbranch="--branch ${mcmodule/*@/}"
    mcmodule=${mcmodule/@*/}
else
    mcbranch=""
fi
mcurl=${mcmodule/git+/}
mcname=$(basename $mcmodule)
mcname=${mcname/.git/}

[[ -f mirgecom/setup.py ]] || git clone --recursive ${mcbranch} ${mcurl}

declare -a module_names
declare -a module_urls
declare -a module_branches

parse_requirements() {
    local MY_MODULES=$(cat mirgecom/requirements.txt)

    for module in $MY_MODULES; do

        if [[ $module == git+* ]]; then
            local module=${module/\#egg=[a-z]*/}

            if [[ $module == *@* ]]; then
                local modulebranch="--branch ${module/*@/}"
                local module=${module/@*/}
            else
                local modulebranch=""
            fi

            local moduleurl=${module/git+/}
            local modulename=$(basename $module)
            local modulename=${modulename/.git/}

            module_names+=("$modulename")
            module_urls+=("$moduleurl")
            module_branches+=("$modulebranch")
        else
            module_names+=("$module")
            module_urls+=("")
            module_branches+=("")
        fi
    done
}
