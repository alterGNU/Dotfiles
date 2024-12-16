#!/usr/bin/env bash

# ============================================================================================================
# This script return the task done by date (pass as argument)
#   - ./get_task_done_by_date.sh 
#   - vimwiki wiki syntax : [...](<pageName>)
#
# - Requirements:
#   - taskwarrior package for task command
#   - coreutils package for date command
#
# ============================================================================================================
 
# =[ VAR ]====================================================================================================
# -[ COLOR BALISE ]-------------------------------------------------------------------------------------------
E="\033[0m"      # END color balise
R0="\033[0;31m"  # START RED
B0="\033[0;36m"  # START BLUE
V0="\033[0;32m"  # START GREEN
M0="\033[0;33m"  # START BROWN
Y0="\033[0;93m"  # START BROWN

# =[ FCTS ]===================================================================================================
# -[ USAGE ]--------------------------------------------------------------------------------------------------
# print usage with specific error message 'arg1' then exit with 'arg2' (if no arg2, default value = 42)
usage()
{
    local txt=${1}
    [[ ${#} -eq 2 ]] && local exit_nb=${2} || local exit_nb=42
    echo -e "${R0}Wrong Usage, err_${exit_nb}${R0}: ${txt}${E}\n${V0}Usage${E}:  \`${B0}./get_task_done_by_date <${M0}date-format${B0}>${E}\`"
    echo -e "- ${B0}<${M0}date-format${B0}> accepted are 'yyyy-mm-dd', 'today', 'yesterday' ... .${E} "
    echo -e "- ${B0}Example:${E}"
    echo -e "  ${R0}\$> ${E}get_task_done_by_date 2024-11-24"
    echo -e "  ID UUID     Created    Completed  Age Project Tags Description"
    echo -e "  -- -------- ---------- ---------- --- ------- ---- ---------------"
    echo -e "   - 43d4d081 2024-11-23 2024-11-24 9d  GPW.Vim wiki Add vim to GPW as submodule"
    echo -e "   - 95ee4fa5 2024-11-24 2024-11-24 8d  GPW.Vim wiki UPDATE Vim.wiki"
    exit ${exit_nb}
}

# ============================================================================================================
# MAIN
# ============================================================================================================
# =[ CHECK ARGUMENTS ]========================================================================================
[[ ${#} -ne 1 ]] && usage "Wrong nb of argument, script need 1args and ${#} was given" 2
[[ $(date -d "${1}" 2> /dev/null) ]] || usage "Arg '${1}' is not a date." 3
task completed end.after:$(date -d "${1}" +%F) end.before:$(date -d "${1} + 1day" +%F)
