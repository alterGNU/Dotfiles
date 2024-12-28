#!/usr/bin/env bash

# ============================================================================================================
# This script should be exec in C or C# project repo. to create a cscope database (cscope.files)
# This script takes no or one argument (if given, should be a path to a C or C# project folder)
#   - ./cscope_build_database.sh                 : Create a new cscope.files for ${PWD} (if exist, replace)
#   - ./cscope_build_database.sh <path_to_folder>: Create a new cscope.files for <path_to_folder> (if exist, replace)
#
# - Requirements:
#   - cscope package for cscope command
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
    echo -e "${R0}Wrong Usage, err_${exit_nb}${R0}: ${txt}${E}\n${V0}Usage${E}:  \`${B0}./cscope_build_database.sh [<${M0}project_folder${B0}>]${E}\`"
    echo -e "- ${B0}<${M0}project_folder${B0}> is optionnal (by default work on \${PWD} )${E} "
    echo -e "- ${B0}Examples:${E}"
    echo -e "  ${R0}\$>${E} ./cscope_build_database.sh"
    echo -e "  ${G0}# Create the file \${PWD}/${V0}cscope.files${E} ${E}"
    echo -e "  ${R0}\$>${E} ./cscope_build_database.sh project_folder"
    echo -e "  ${G0}# Create the file ${M0}project_folder${E}/${V0}cscope.files${E} ${E}"
    exit ${exit_nb}
}
 
# ============================================================================================================
# MAIN
# ============================================================================================================
# =[ CHECKS ]=================================================================================================
[[ ${#} -gt 1 ]] && usage "Wrong nb of argument, command need 0 or 1 arg and ${#} was given" 2
[[ ( -n ${1} ) && ( ! -d ${1} ) ]] && usage "Not a folder, '${M0}${1}${E}' is not a folder" 2
[[ ${#} -eq 0 ]] && PRODIR=${PWD} || PRODIR=$(realpath ${1})
[[ -f "${PRODIR}/cscope.files" ]] && rm ${PRODIR}/cscope.files
find ${PRODIR} -regextype posix-egrep -iregex ".+\.(c|cc|cpp|h|hpp)$" -print >> ${PRODIR}/cscope.files
cd ${PRODIR} && cscope -Rbkq
echo -e "'${B0}$(basename ${PRODIR})${E}' project database successfully created."
#if [[ -f "${PRODIR}/cscope.out" ]];then
#    CSCOPE_DB="${PRODIR}/cscope.out"
#    export CSCOPE_DB
#else
#    echo -e "${R0}Something went wrong, no cscope.out file created.${E}"
#    rm "${PRODIR}/cscope.out"
#fi
