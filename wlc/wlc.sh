#!/usr/bin/env bash

# ============================================================================================================
# This script convert switch markdown links of github project wikis between:
#   - github wiki syntax  : [...](github.com/<userName>/<projectName>/<pageName>)
#   - vimwiki wiki syntax : [...](<pageName>)
#
#
# TODO
# - [X] Manage link to insert image. 1[](...)
# - [X] Manage link to paragraphe.
# - [X] Manage 2 links in the same line.
# - [X] Manage description having bracket [toto9(titi)](tutu) -> extract_link=tutu and not titi
# - [ ] add Quiet version (-q=0 print all, -q=1 print only match, -q=2 dont print anything)
# ============================================================================================================

# =[ VAR ]====================================================================================================
LEN=120
# -[ MODE ]---------------------------------------------------------------------------------------------------
GITMODE=""
MDMODE=""
# -[ COLOR BALISE ]-------------------------------------------------------------------------------------------
E="\033[0m"      # END color balise
R0="\033[0;31m"  # START RED
B0="\033[0;36m"  # START BLUE
V0="\033[0;32m"  # START GREEN
M0="\033[0;33m"  # START BROWN
Y0="\033[0;93m"  # START BROWN
# -[ PATH ]---------------------------------------------------------------------------------------------------
ABS_PATH=""
FOLDNAME=""

# =[ FCTS ]===================================================================================================
# -[ GET_REAL_LEN() ]-----------------------------------------------------------------------------------------
get_real_len() { echo $(echo -en "${1}" | sed 's/\x1b\[[0-9;]*m//g' | wc -m); }
# -[ PRINT N TIMES ]------------------------------------------------------------------------------------------
# print arg1 arg2 times 
pnt() { for i in $(seq 0 $((${2})));do echo -en ${1};done;}
# -[ PRINT LINK LINE ]----------------------------------------------------------------------------------------
print_link_line()
{
    local s1=$(get_real_len "${1}")
    local s2=$(get_real_len "${2}")
    local nb_space=$((LEN - s1 - s2))
    if [[ ${nb_space} -gt 0 ]];then
        echo -en "${1}"
        pnt "." ${nb_space}
        echo -en "${2}\n"
    else
        echo -e "${1}${2}"
    fi
}
# -[ USAGE ]--------------------------------------------------------------------------------------------------
# print usage with specific error message 'arg1' then exit with 'arg2' (if no arg2, default value = 42)
usage()
{
    local txt=${1}
    [[ ${#} -eq 2 ]] && local exit_nb=${2} || local exit_nb=42
    echo -e "${R0}Wrong Usage, err_${exit_nb}${R0}: ${txt}${E}\n${V0}Usage${E}:  \`${B0}./wlc ${M0}<-g(or)-m> <path_to_wiki_folder>${E}\`"
    echo -e "-${B0} ./wlc ${M0}-g(or --github)  ${M0}<git_wiki_folder>${E}: In ${M0}<git_wiki_folder>${E} convert every markdown link to github syntax (from file to html)"
    echo -e "-${B0} ./wlc ${M0}-m(or --markdown) ${M0}<git_wiki_folder>${E}: In ${M0}<git_wiki_folder>${E} convert every markdown link to vimwiki syntax (from html to file)\n"
    exit ${exit_nb}
}

# -[ GET_URL ]------------------------------------------------------------------------------------------------
# return clean url (from git remote command, if ssh or html remote)
get_url()
{
    local url=$(cd ${ABS_PATH} && git remote -v | head -1 | awk -F ' ' '{print $2}')
    if [[ -n "${url}" ]];then
        if [[ "${url}" == *.wiki.git ]];then 
            url=${url/\.wiki\.git/\/wiki/}
            if [[ "${url}" != https* ]];then 
                url="https://github.com/${url#*github.com:}" # Case remote is a SSH
            else
                url=${url/\.wiki/\/wiki/}                    # Case remote is a HTTPS
            fi
            echo ${url}
        else
            echo "0"                                         # Case remote is not a wiki
        fi
    else
        echo ${url}                                          # Case no remote (url empty)
    fi
}

# -[ REPLACE_LINK ]-------------------------------------------------------------------------------------------
# set all find link to wiki format depending on active mode.
replace_links()
{
    # HEADER
    local title="- ${FOLDNAME}/$(basename ${1}) :" && echo -n ${title} && pnt "-" $((LEN - ${#title})) && echo

    echo ${1} | while read -r file; do
        sed -n -E '/\[.*\]\(.*\)/{=;p}' "${file}" | while read -r line_number; do read -r matched_line
            # Check link to insert images ![...](..)
            echo "${matched_line}" | awk ' { while (match($0, /!\[([^\]]*)\]\(([^)]+)\)/, arr)) { print arr[1] "\n" arr[2]; $0 = substr($0, RSTART + RLENGTH); } }' | while read -r extract_name ; do read -r extract_link
                local suffixe="${extract_link#${URL}}"
                local found_file=$(find "${ABS_PATH}" -type f -iname "${suffixe}.md" -print -quit)
                local found_link=$(find "${ABS_PATH}" -type f -iname "${extract_link}" -print -quit)
                print_link_line "$(printf "  - 🟨 ${Y0}line-%03d: ![${extract_name}](${extract_link})" ${line_number} )" "is a link to an image.${E}"
            done
            # Anything but ![]()
            echo "${matched_line}" | awk ' { while (match($0, /[^!]\[([^\]]+)\]\(([^)]+)\)/, arr)) { print arr[1] "\n" arr[2]; $0 = substr($0, RSTART + RLENGTH); } }' | while read -r extract_name ; do read -r extract_link
                local suffixe="${extract_link#${URL}}"
                local found_file=$(find "${ABS_PATH}" -type f -iname "${suffixe}.md" -print -quit)
                local found_link=$(find "${ABS_PATH}" -type f -iname "${extract_link}" -print -quit)
                # SEARCH html-syntax TO CONVERT INTO markdown-syntax
                if [[ ${extract_link:0:1} == "#" ]];then
                    print_link_line "$(printf "  - 🟨 ${Y0}line-%03d: [${extract_name}](${extract_link})" ${line_number} )" "is a link to a title.${E}"
                elif [[ ( ${extract_link:0:3} == "www" ) || ( ( ${extract_link:0:3} == "htt" ) && ( ! ${extract_link} =~ ${URL} ) ) ]];then
                    print_link_line "$(printf "  - 🟦 ${B0}line-%03d: [${extract_name}](${extract_link})" ${line_number} )" "is a link to a webpage.${E}"
                elif [[ -n "${MDMODE}" ]];then
                    if [[ ${extract_link} =~ ${URL} ]];then
                        if [[ -n ${found_file} ]];then
                            local new_value="$(basename ${found_file})"
                            print_link_line "$(printf "  - ✅ ${V0}line-%03d: [${extract_name}](${extract_link})" ${line_number} )" "➡️ [${extract_name}](${new_value})${E}"
                            sed -i "${line_number}s|\[${extract_name}\](${extract_link})|[${extract_name}](${new_value})|" "${file}"
                        else
                            print_link_line "$(printf "  - 🟥 ${R0}line-%03d: [${extract_name}](${extract_link})" ${line_number})" "is a github-html-link to a a non-existing-page${E}"
                        fi
                    else
                        if [[ -n "${found_link}" ]];then
                            print_link_line "$(printf "  - 🟩 ${V0}line-%03d: [${extract_name}](${extract_link})" ${line_number} )" "is already in MARKDOWN-SYNTAX.${E}"
                        else
                            print_link_line "$(printf "  - 🟥 ${R0}line-%03d: [${extract_name}](${extract_link})" ${line_number} )" "not a link to an existing file in MDMODE${E}"
                        fi
                    fi
                else # SEARCH markdown-syntax TO CONVERT INTO html-syntax
                    if [[ -n "${found_link}" ]]; then
                        local new_filename="${extract_link%\.*}"
                        local new_value="${URL}${new_filename,,}"
                        print_link_line "$(printf "  - ✅ ${V0}line-%03d: [${extract_name}](${extract_link})" ${line_number} )" "➡️ [${extract_name}](${new_value})${E}"
                        sed -i "${line_number}s|\[${extract_name}\](${extract_link})|[${extract_name}](${new_value})|" "${file}"
                    else
                        if [[ ( "${extract_link}" =~ "${URL}" ) && ( -n ${found_file} ) ]];then
                            print_link_line "$(printf "  - 🟩 ${V0}line-%03d: [${extract_name}](${extract_link})" ${line_number} )" "is already in HTML-SYNTAX.${E}"
                        else
                            print_link_line "$(printf "  - 🟥 ${R0}line-%03d: [${extract_name}](${extract_link})" ${line_number} )" "not a file in GITMODE${E}"
                        fi
                    fi
                fi
            done
        done
    done
}

 
# ============================================================================================================
# MAIN
# ============================================================================================================
# =[ CHECK ARGUMENTS ]========================================================================================
[[ ${#} -ne 2 ]] && usage "Wrong nb of argument, script need 2args and ${#} was given" 2
ABS_PATH=$(realpath ${2})
FOLDNAME=$(basename ${ABS_PATH})
[[ ! -d ${ABS_PATH} ]] && usage "Last arg \"${FOLDNAME}\" is not a folder" 3
[[ ( ! -d "${ABS_PATH}/.git" ) && ( ! -f "${ABS_PATH}/.git" ) ]] && usage "arg \"${FOLDNAME}\" is not git repo." 4
# =[ SET MODE ]===============================================================================================
case "${1}" in
    -g|--github) GITMODE="ok" ;; 
    -m|--markdown) MDMODE="ok";;
    *) usage "arg1 is not an option: \"${1}\"" 5 ;;
esac
# =[ GET_URL ]================================================================================================
URL=$(get_url)
[[ -z "${URL}" ]] && usage "git repo \"${FOLDNAME}\" has no remote " 6
[[ "${URL}" == "0" ]] && usage "git repo \"${FOLDNAME}\" is not a github wiki repo" 7
# =[ SEARCH FILES FOR LINKS ]=================================================================================
pnt '=' ${LEN} && echo
[[ ${GITMODE} == "ok" ]] && echo -e "CONVERT FROM MARKDOWN TO HTML" || echo -e "CONVERT FROM HTML TO MARKDOWN"
pnt '=' ${LEN} && echo
for file in $(ls ${ABS_PATH});do
    [[ ${file} == *.md ]] && replace_links "${ABS_PATH}/${file}"
done
pnt "=" ${LEN}
