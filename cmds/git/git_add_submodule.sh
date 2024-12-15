#!/usr/bin/env bash
 
# ============================================================================================================
# MAIN
# ============================================================================================================
if [ ${#} -eq 1 ];then
    local sub_url=${1}
    local sub_path=${1}
elif [ ${#} -eq 2 ];then
    local sub_url=${1}
    local sub_path=${2}
else
    echo "\033[0;31mWrong Usage: take 1 or 2 arguments\033[0m"
fi
echo 'git submodule add ${sub_url} ${sub_path} && git add --all && git commit -m"ADD Submodule: ${sub_path}"'
