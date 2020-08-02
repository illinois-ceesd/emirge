#!/bin/bash

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
