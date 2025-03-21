#!/usr/bin/env bash

# ============================================================================================================
# This script should be exec in a git repo. to add by url another repo. as submodule
#   - ./git_add_submodule.sh <sub_url> [<sub_path>]
#       - 1 | Add sub_module
#       - 2 | Commit
#
# - Requirements:
#   - git package for git command
# ============================================================================================================

# =[ VAR ]====================================================================================================
# -[ COLOR BALISE ]-------------------------------------------------------------------------------------------
E="\033[0m"      # END color balise
R0="\033[0;31m"  # START RED
B0="\033[0;36m"  # START BLUE
V0="\033[0;32m"  # START GREEN
M0="\033[0;33m"  # START BROWN
G0="\033[0;90m"  # START GREY

# =[ FCTS ]===================================================================================================
# -[ USAGE ]--------------------------------------------------------------------------------------------------
# print usage with specific error message 'arg1' then exit with 'arg2' (if no arg2, default value = 42)
usage()
{
    local txt=${1}
    [[ ${#} -eq 2 ]] && local exit_nb=${2} || local exit_nb=42
    echo -e "${R0}Wrong Usage, err_${exit_nb}${R0}: ${txt}${E}\n${V0}Usage${E}:  \`${B0}./git_add_submodule.sh <${M0}sub_url${B0}> [<${M0}sub_path${B0}>]${E}\`"
    echo -e "- ${B0}<${M0}sub_url${B0}> is mandatory${E} "
    echo -e "- ${B0}<${M0}sub_path${B0}> is optionnal (by default: ./repo_name)${E} "
    echo -e "- ${B0}Examples:${E}"
    echo -e "  ${R0}\$> ${V0}git_add_submodule${E} \"https://github.com:toto/titi.git\""
    echo -e "  ${G0}# add titi as submodule of actual git repo, at \"./titi/*\"${E}"
    echo -e "  ${R0}\$> ${V0}git_add_submodule${E} \"https://github.com:toto/titi.git\" \"toto/tutu\""
    echo -e "  ${G0}# add titi as submodule of actual git repo, at \"./toto/tutu/*\"${E}"
    exit ${exit_nb}
}
 
# ============================================================================================================
# MAIN
# ============================================================================================================
# =[ CHECKS ]=================================================================================================
[[ ( ${#} -gt 2 ) || ( ${#} -eq 0 ) ]] && usage "Wrong nb of argument, command need 1 or 2 args and ${#} was given" 2
if ! git rev-parse --is-inside-work-tree &>/dev/null;then
    usage "Not in a git repo, ${M0}${PWD}${E} is not a git repo!" 3
fi
if [ ${#} -eq 1 ];then
    git submodule add --force ${1}
else
    git submodule add --force ${1} ${2}
fi
[[ ${?} -ne 0 ]] && usage "Can not add submodule." 4
git submodule update --init --recursive && git add --all && git commit -m"ADD Submodule"
