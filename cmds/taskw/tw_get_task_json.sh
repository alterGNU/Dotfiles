#!/usr/bin/env bash

# ============================================================================================================
# This script display in stdout AND copy to CLIPBOARD the task json format(task_ID pass as arguments)
#   - ./tw_get_task_json.sh <task_ID>
#
# - Requirements:
#   - taskwarrior package for task command
#   - coreutils package for tee command
#   - xsel package for xsel command (wl-copy omly work in Wayland, xsel work on X11 and wayland).
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
    echo -e "${R0}Wrong Usage, err_${exit_nb}${R0}: ${txt}${E}\n${V0}Usage${E}:  \`${B0}./tw_get_task_json <${M0}task_id>${E}\`"
    echo -e "- ${B0}<${M0}task_id${B0}> accepted are task.ID or task.UUID${E} "
    echo -e "- ${B0}Example:${E}"
    echo -e "  ${R0}\$> ${E}tw_get_task_json 11"
    echo -e "[\n {\"id\":11,\"description\":\"talk to toto about titi\",\"entry\":\"20241125T102537Z\",\"modified\":\"20241126T070157Z\",\"project\":\"tutu\",\"status\":\"pending\",\"uuid\":\"111f1119-fcbc-4a6f-ac34-9c545bbcd8eb\",\"tags\":[\"tata\"],\"depends\":[\"de93a02c-a6ce-4616-854f-89e6ef93cb48\"],\"urgency\":-3.09041}\n ]"
    exit ${exit_nb}
}

# ============================================================================================================
# MAIN
# ============================================================================================================
# =[ CHECK ARGUMENTS ]========================================================================================
[[ ${#} -ne 1 ]] && usage "Wrong nb of argument, script need 1arg and ${#} was given" 2
task ${1} export | tee >(xsel -ib)
