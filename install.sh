#!/usr/bin/env bash

# ============================================================================================================
# INSTALL SCRIPT
# install my conf.: make backup folder with actual dotfiles before replacing them with sym-links to my dotfiles
#
# INSTALL COMMANDS
# - If git install  : `git clone --recurse-submodules -j8 https://github.com/alterGNU/Dotfiles.git && ./Dotfiles/install.sh`
# - If curl install : `sh -c "$(curl -fsSL https://raw.githubusercontent.com/alterGNU/Dotfiles/refs/heads/main/install.sh)`
# - If wget install : `sh -c "$(wget -O- https://raw.githubusercontent.com/alterGNU/Dotfiles/refs/heads/main/install.sh)`
#
# GOOD-TO-KNOW
# - Variables       : 
#   - if the comment start with ☑ , that means its value can be change by the user.
#   - if the comment start with ☒ , that means its value can NOT be change by the user.
# - Dotfiles project can be clone anywhere, this script will create ENV-VAR and symbolic-links so that the dotfiles work.
#
# TODO :
#   - FEATURES:
#       - [ ] CREATE LOG FILES      : Instead of /dev/null, redirect in log file...(I can gitignore theses files and put then in DOTPATH)
#       - [ ] CREATE INSTALL-MODE   : Install after classic git-cloned ( Inside the Dotfiles folder)
#       - [ ] CREATE INSTALL-MODE   : Install alone with curl or wget on raw-files-install.script ( Not Inside the Dotfiles folder)
#       - [ ] UN-INSTALL            : Create an un-install command remove all changes done by this script and re-install newest backup made
#                                     ⤷ write an undo_fun by install_fun: config_zsh 🡲 undo_zsh
#       - [ ] ZSH CUSTOM FUNCTIONS  : For now, only bash script custom fun are handle.
#                                     ⤷ ADD binary      : C compiled home-made commands
#                                     ⤷ ADD zsh-func    : file name after the fun, add to $FPATH, autoload in zshr
#       - [ ] MODULAR INSTALL       : Allow user to choose the configuration with arg to chose the option to install:
#                                     ⤷ if nothing then install all (Ex :`./install.sh`)
#                                     ⤷ else, install pre-requis always then [-z:zsh, -g:git, -v:vim, -t:taskw, -o:other_tools, -d:desk_env] (Ex: `./install.sh -zgod`)
#   - INSTALL FUN:
#       - config_taskw()
#           - [ ] Add taskserver package and config file (server & client)
#       - config_desk_env()
#           - [ ] Handle other desktop terminal (raspbian-11 not handle)
# FIXME :
# - [ ] Backup folder and file names start with a dot (hidden) 🡲 remove starting dot if exist.
# ============================================================================================================
 
# ============================================================================================================
# VAR
# ============================================================================================================
# =[ PRE_REQUIS_CMDS ]========================================================================================
# Dict of command:package needed by this script (always check at start)
# coreutils package is check for multiple commands = tee, date, direname, realpath , mktemp, whoami
declare -A PRE_REQUIS_CMDS=( \
    ["curl"]="curl" \
    ["find"]="findutils" \
    ["git"]="git" \
    ["grep"]="grep" \
    ["sed"]="sed" \
    ["tee"]="coreutils" \
    ["usermod"]="passwd" \
    ["which"]="which" \
    ["xsel"]="xsel" \
)
# =[ FOLDERS ]================================================================================================
BCK="${HOME}/backups"                                     # ☑ Path of the backup folder
FLD="${BCK}/$(date +%Y_%m_%d.%Hh%Mm%Ss)"                  # ☒ Name of the backup folder
DOTPATH=$(dirname $(realpath ${0}))                       # ☒ Path of the Dotfile folder (⚠ TO CHANGE WHEN INSTALL WITH CULR/WGET IMPLEMENTED ⚠ )
CUSTOM_CMD_BIN_FOLDER="${HOME}/.local/bin"                # ☑ Folder where bin/custom cmd link are store (add to PATH ENV-VAR.)
ACTIVE_ALIASES_FOLDER="${DOTPATH}/active_custom_aliases"  # ☒ Folder where actives aliases files are store (source in zshrc)
# =[ LAYOUT ]=================================================================================================
LEN=110                                                   # ☑ Width of the box(line size of this script stdout)
# -[ COLORS ]-------------------------------------------------------------------------------------------------
R="\033[1;31m"                                            # ☒ START RED
G="\033[1;32m"                                            # ☒ START GREEN
M="\033[1;33m"                                            # ☒ START BROWN
U="\033[4;29m"                                            # ☒ START UNDERSCORED
B="\033[1;36m"                                            # ☒ START BLUE
Y="\033[0;93m"                                            # ☒ START YELLOW
BY="\033[5;93m"                                           # ☒ START BLINKING YELLOW
LB="\033[1;96m"                                           # ☒ START LIGHT BLUE
E="\033[0m"                                               # ☒ END COLOR BALISE
# Dict key:colors name/abbrev -> value:color-balise (used by print_in_box to convert option value into color-balise)
declare -A COLORS=( \
    ["w"]="\033[1;29m" ["white"]="\033[1;29m" ["W"]="\033[1;29m" ["WHITE"]="\033[1;29m" \
    ["r"]="\033[1;31m" ["red"]="\033[1;31m" ["R"]="\033[1;31m" ["RED"]="\033[1;31m" \
    ["g"]="\033[1;32m" ["green"]="\033[1;32m" ["G"]="\033[1;32m" ["GREEN"]="\033[1;32m" \
    ["m"]="\033[1;33m" ["marron"]="\033[1;33m" ["M"]="\033[1;33m" ["MARRON"]="\033[1;33m" ["brown"]="\033[1;33m" ["BROWN"]="\033[1;33m"\
    ["b"]="\033[1;36m" ["blue"]="\033[1;36m" ["B"]="\033[1;36m" ["BLUE"]="\033[1;36m" \
    ["y"]="\033[0;93m" ["yellow"]="\033[0;93m" ["Y"]="\033[0;93m" ["YELLOW"]="\033[0;93m" \
    ["bw"]="\033[5;29m" ["blinking-white"]="\033[5;29m" ["BW"]="\033[5;29m" ["BLINKING-WHITE"]="\033[5;29m" \
    ["br"]="\033[5;31m" ["blinking-red"]="\033[5;31m" ["BR"]="\033[5;31m" ["BLINKING-RED"]="\033[5;31m" \
    ["bg"]="\033[5;32m" ["blinking-green"]="\033[5;32m" ["BG"]="\033[5;32m" ["BLINKING-GREEN"]="\033[5;32m" \
    ["bm"]="\033[5;33m" ["blinking-marron"]="\033[5;33m" ["BM"]="\033[5;33m" ["BLINKING-MARRON"]="\033[5;33m" ["blinking-brown"]="\033[5;33m" ["BLINKING-BROWN"]="\033[5;33m"\
    ["bb"]="\033[5;36m" ["blinking-blue"]="\033[5;36m" ["BB"]="\033[5;36m" ["BLINKING-BLUE"]="\033[5;36m" \
    ["by"]="\033[5;93m" ["blinking-yellow"]="\033[5;93m" ["BY"]="\033[5;93m" ["BLINKING-YELLOW"]="\033[5;93m" \
)
# -[ BOX ]----------------------------------------------------------------------------------------------------
#      0   1   2   3                                      # ☒ 0:simple, 1:bold, 2:double, 3:round
ULC=( "┌" "┏" "╔" "╭" )                                   # ☒ Upper Left Corner
DLC=( "└" "┗" "╚" "╰" )                                   # ☒ Down Left Corner
URC=( "┐" "┓" "╗" "╮" )                                   # ☒ Upper Right Corner
DRC=( "┘" "┛" "╝" "╯" )                                   # ☒ Down Right Corner
  H=( "─" "━" "═" "─" )                                   # ☒ Horizontal
  V=( "│" "┃" "║" "│" )                                   # ☒ Vertical
 UT=( "┬" "┳" "╦" "┬" )                                   # ☒ Upper T
 DT=( "├" "┣" "╠" "├" )                                   # ☒ Down T
 MC=( "┼" "╋" "╬" "┼" )                                   # ☒ Middle Cross
 RT=( "┤" "┫" "╣" "┤" )                                   # ☒ Right T
 LT=( "┴" "┻" "╩" "┴" )                                   # ☒ Left T
# -[ TEXT TO DISPLAY ]----------------------------------------------------------------------------------------
FINAL_MESSAGE=( "${Y}❖ ${U}INSTALLATION COMPLETE${E} ${Y}❖${E}" ) # ☒ Text to display at the end

# ============================================================================================================
# FUNCTIONS
# ============================================================================================================
# =[ UTILS SYM-LINK FCTS ]====================================================================================
# -[ SHORT_PATH ]---------------------------------------------------------------------------------------------
# Replace long path by Variable name /home/user/toto/titi -> ${HOME}/toto/titi
short_path()
{
    local short=${1/${DOTPATH}/\$\{DOTPATH\}}
    local short=${short/${HOME}/\$\{HOME\}}
    echo ${short}
}
# -[ IS_A_VALID_SYMLINK ]-------------------------------------------------------------------------------------
# Check if the arg1 is a valid symbolic link
is_a_valid_symlink(){ [ -L "${1}" ] && [ -e "$(readlink -f "${1}")" ] ; }
# -[ DEL_SYMLINK ]--------------------------------------------------------------------------------------------
# If arg1 is a path to a synbolic link, delete it
del_symlink()
{ 
    if [[ -h "${1}" ]];then
        local solved_link=$(readlink -f "${1}")
        rm "${1}"
        echol "${U}rm sym-link${E}: '${LB}$(short_path ${1})${E}' ➟  '${M}$(short_path ${solved_link})${E}'" "3"
    fi
}
# -[ CREATE SYM-LINK ]----------------------------------------------------------------------------------------
# create a sym-link from arg1 to arg2 (if arg2 already exists, do nothing)
create_symlink()
{
    if [[ -L "${2}" ]];then
        local old_link=$(readlink -f "${1}")
        if [[ "${old_link}" == "${1}" ]];then
            echol "${U}Link already exist${E}: '${LB}$(short_path ${2})${E}' ➟ '${M}$(short_path ${1})${E}'" "3"
        else
            echol "${U}Link already exist${E}: '${LB}$(short_path ${2})${E}' ${R}↛${E} '${M}$(short_path ${1})${E}'" "3"
            echol "                                            ${G}⮡${E} '${M}${old_link}${E}'" "3"
        fi
    else
        ln -s "${1}" "${2}" && echol "${U}Create sym-link${E}: '${LB}$(short_path ${2})${E}' ➟ '${M}$(short_path ${1})${E}'" "3" || { echol "${R}FAILED to create sym-link: '${LB}$(short_path ${2})${R}' ➟ '${M}$(short_path ${1})${E}'" "3" && exit 3 ; }
        if ! is_a_valid_symlink "${2}";then
            echol "${R}Sym-link created not valid:'${LB}$(short_path ${2})${R}' ➟ '${M}$(short_path ${1})${E}'" "5"
            rm "${2}" && echol "${R}Sym-link '${LB}$(short_path ${2})${R}' REMOVED!" "5"
            return 3;
        fi
    fi
}
# -[ RM_BROKEN_LINK_FROM_FOLDER ]-----------------------------------------------------------------------------
# if exist, check all its link, if dead, rm them
rm_broken_link_from_folder()
{
    if [[ -d ${1} ]];then
        for symlink in "${1}"/*;do if ! is_a_valid_symlink "${symlink}";then del_symlink ${symlink};fi done
    else
        local short1=${1/${DOTPATH}/\$\{DOTPATH\}}
        local short1=${short1/${HOME}/\$\{HOME\}}
        echo "${R}Wrong usage of ${B}rm_broken_link_from_folder${R}: ${M}${1}${R} is not a folder${E}"
    fi
}
# =[ UTILS PRINT AND DISPLAY TEXT FCTS ]======================================================================
# -[ GET_LEN ]------------------------------------------------------------------------------------------------
# return real len
get_len() { echo $(echo -en "${1}" | sed 's/\x1b\[[0-9;]*m//g' | wc -m) ; }
# -[ PRINT N TIMES ]------------------------------------------------------------------------------------------
# print SEP LEN times
pnt() { for i in $(seq 0 $((${2})));do echo -en ${1};done ; }
# -[ PRINT_TITLE ]--------------------------------------------------------------------------------------------
print_title()
{
    local titre="${Y}${1}${E}"
    local size=$(get_len "${titre}")
    echo -en "${ULC[2]}" && pnt ${H[2]} $(( size + 1 )) && echo -en "${URC[2]}\n"
    echo -en "${V[2]} ${titre} ${DT[2]}" && pnt "${H[2]}" $((LEN - $(get_len "${titre}") - 5 )) && echo -en "${URC[2]}\n"
    echo -en "${DT[2]}" && pnt ${H[2]} $(( size + 1 )) && echo -en "${DRC[2]}"
    pnt "\x20" $((LEN - $(get_len "${titre}") - 5 )) && echo -en "${V[2]}\n"
}
print_last() { echo -en "${DLC[2]}" && pnt ${H[2]} $(( LEN - 2 )) && echo -en "${DRC[2]}\n" ; }
# -[ ECHO LINE ]----------------------------------------------------------------------------------------------
# echo line inside the box (arg2 optionnal=indentation with custom. list items symb.)
echol()
{
    local sym=( "${Y}✦${E}" "${Y}➣${E}" "${Y}➣${E}"  "${Y}⤷${E}" "${Y}⤷${E}" "${Y}⤷${E}" "${Y}⤷${E}" )
    [[ ${#} -eq 1 ]] && local indent=1 || local indent=${2}
    local sym=${sym[$(((${indent} % ${#sym[@]})-1))]}
    local spaces=$(printf ' %.s' $(seq 1 ${indent}))
    local line="${V[2]}${spaces}${B}${sym}${E} ${1}"
    local size=$(get_len "${line}")
    echo -en "${line}"
    pnt "\x20" $(( LEN - size - 1 ))
    [[ ${LEN} -gt $(( size + 1 )) ]] && echo -en "${V[2]}\n" || echo -en "\n"
}
# -[ END_MESSAGE ]--------------------------------------------------------------------------------------------
# Print last-arg in a box:
# This function have -c or --color option (default none, accepte:r,red,b,blue,y,yellow,
print_in_box()
{
    local color_code="white"
    local box_type="0"
    local text=( )
    # HANDLE OPTION
    while [[ ${#} -gt 0 ]];do
        case "${1}" in
            -c|--color)
                local color_code="${2}"
                shift 2
                ;;
            -t|--type)
                local box_type="${2}"
                shift 2
                ;;
            *)
                text+=("${1}")
                shift
                ;;
        esac
    done
    # CHECK IF COLOR VALUE IS IN DICT-COLORS
    local C="${COLORS["w"]}"
    [[ -n "${COLORS[${color_code}]}" ]] && C=${COLORS[${color_code}]} || echo -e "${R}WRONG OPTION:--color='${M}${color_code}${R}' INVALID VALUE ⇒ keep default value:${U}WHITE.${E}"
    # CHECK IF TYPE VALUE IN RANGE
    [[ ( ! "${box_type}" =~ ^[0-9]+$ ) || ( ${box_type} -lt 0 ) || ( ${box_type} -gt 3 ) ]] && { echo -e "${R}WRONG OPTION:--type='${M}${box_type}${R}' INVALID VALUE ⇒ keep default value:${U}0 for 'SIMPLE-LINE-BOX'.${E}" && local box_type="0" ; }

    # PRINT THE BOX
    echo -en "${C}${ULC[${box_type}]}" && pnt "${H[${box_type}]}" $((LEN-2)) && echo -en "${URC[${box_type}]}\n"
    for line in "${text[@]}";do
        local line="${C}${V[${box_type}]}${E} ${line}"
        local size=$(get_len "${line}")
        echo -en "${line}" && pnt "\x20" $(( LEN - size - 1 )) && echo -en "${C}${V[${box_type}]}${E}"
        [[ ${LEN} -gt $(( size + 1 )) ]] && echo -en "${sym}\n" || echo -en "\n"
    done
    echo -en "${C}${DLC[${box_type}]}" && pnt "${H[${box_type}]}" $((LEN-2)) && echo -en "${DRC[${box_type}]}\n"
}
# =[ UTILS MANIP. FILES AND FOLDERS FCTS ]====================================================================
# -[ INSERT_LINE_IN_FILE_UNDER_MATCH ]------------------------------------------------------------------------
# If not already there, insert <line>(arg1) in <file>(arg2) under the <matching_line>(arg3
#   - If arg3:opt given and found : insert <line> under <matching_line> in <file>
#   - else (arg3 given but not found OR not given) : insert <line> at the end of <file>
insert_line_in_file_under_match()
{
    local fun_name="insert_line_in_file_under_match"
    [[ ( ${#} -lt 2 ) || ( ${#} -gt 3 ) ]] && { echo -e "${R}Wrong Usage of ${G}${fun_name}${R}, take 2 or 3 args, ${#} were given" && exit 1 ; }
    [[ ! -f ${2} ]] && { echo -e "${R}Wrong Usage of ${G}${fun_name}${R}, arg2:'${M}${2}${R}' is not a file" && exit 1 ; }
    if grep -x -q "${1}" "${2}";then
        echol "line:'${G}$(short_path ${1})${E}' was already in file:'${M}$(short_path ${2})${E}'." "3"
    else
        if [[ -n ${3} ]] && grep -E -q "${3}" "${2}";then
            sed -i "/${3}/a\\${1}" "${2}" && echol "line '${B}$(short_path ${1})${E}' insert successfully in file=${M}$(short_path ${2})${E}" "3"
        else
            echo "${1}" >> "${2}" && echol "line '${B}$(short_path ${1})${E}' append successfully to EOF of ${M}$(short_path ${2})${E}" "3"
        fi
    fi
}
# -[ MKDIR_IF_NOT_EXIST() ]-----------------------------------------------------------------------------------
# create a directory if not already created
mkdir_if_not_exist()
{ 
    if [[ ! -d "${1}" ]];then
        mkdir -p "${1}" && echol "${U}Mkdir:${E}'${B}$(short_path ${1})${E}', directory successfully created." "3" || echol "${R}FAILED to create '${M}$(short_path ${1})${E}' directory" "3"
    else
        echol "${U}No mkdir of:${E}'${B}$(short_path ${1})${E}', directory was already created." "3"
    fi
}
# -[ SAVE_FILE ]----------------------------------------------------------------------------------------------
# If arg1 is a path to a file, make a backup. The backup name can be manually provide by arg2 (opt)
save_file()
{
    del_symlink "${1}"
    if [[ -f "${1}" ]];then
        [[ -n "${2}" ]] && local dst_filename="${2}" || local dst_filename=$(basename "${1}")
        mkdir_if_not_exist "${FLD}/${dst_filename}"
        mv "${1}" "${FLD}/${dst_filename}" && echol "${U}Create backup-file${E}: '${FLD}/${dst_filename}'" "3"
    fi
}
# -[ SAVE_FOLDER ]--------------------------------------------------------------------------------------------
# If arg1 is a path to a folder, make a backup. The backup name can be manually provide by arg2 (opt)
save_folder()
{
    del_symlink "${1}"
    if [[ -f "${1}" ]];then
        [[ -n "${2}" ]] && local dst_foldername="${2}" || local dst_foldername=$(basename "${1}")
        mkdir_if_not_exist "${FLD}/${dst_filename}"
        mv "${1}" "${FLD}/${dst_foldername}" && echol "${U}Create backup-folder${E}:'${FLD}/${dst_foldername}'" "3"
    fi
}
# =[ CMDS UTILES FCTS ]=======================================================================================
# -[ EXEC_ANIM() ]--------------------------------------------------------------------------------------------
# print animation in frontground while cmd exec in background the print returns.
exec_anim()
{
    local frames=( 🕛  🕒  🕕  🕘 )
    local delay=0.1 
    local cmd="${@}"
    local tmpfile=$(mktemp "${TMPDIR:-/tmp}/exec_anim_${cmd%% *}_XXXXXX")
    trap '[[ -f "${tmpfile}" ]] && rm -f "${tmpfile}"' EXIT RETURN
    ${@} > "${tmpfile}" 2>&1 &
    local pid=${!}
    while kill -0 ${pid} 2>/dev/null; do
        for frame in "${frames[@]}"; do echo -en "${V[2]} " && printf "${frame}\r" && sleep ${delay} ; done
    done
    printf "\r" && wait ${pid}
    local exit_code=${?}
    printf "\r" && cat "${tmpfile}"
    return ${exit_code}
}
# -[ COMMAND_EXISTS ]-----------------------------------------------------------------------------------------
# Check if a command is installed
command_exists(){ command -v "${1}" > /dev/null 2>&1 ; }
# -[ INSTALL_CMD ]--------------------------------------------------------------------------------------------
# Check if command is installed, else install it
install_cmd()
{
    local cmd_name=${1}
    local pck_name=${1}
    [[ ${#} -eq 2 ]] && local pck_name=${2}
    if command_exists "${cmd_name}";then
        echol "pck ${B}${pck_name}${E} already installed." "3"
    else
        exec_anim "sudo apt-get install -y ${pck_name}" && \
        { echol "pck ${B}${pck_name}${E} successfully installed." "3" && FINAL_MESSAGE+=("    ${Y}‣${E} ${B}${pck_name}${E} package successfully installed." ) ; } || \
        echol "${R}FAILED to install pck ${B}${pck_name}${E}." "3"
    fi
}

# -[ PACKAGE_INSTALLED ]--------------------------------------------------------------------------------------
# Check if a package was installed
pck_installed(){ dpkg-query -W -f='${Status}' "${1}" 2>/dev/null | grep -q "install ok installed" ; }
# -[ INSTALL_PCK ]--------------------------------------------------------------------------------------------
# Check if a package is installed, else install it
install_pck()
{
    if pck_installed "${1}";then
        echol "pck ${B}${1}.deb${E} was already installed." "3"
    else
        pkexec dpkg -i ${1}.deb > /dev/null 2>&1 && \
            { echol 'pck ${B}${1}.deb${E} installed successfully' '3' && FINAL_MESSAGE+=("    ${Y}‣${E} ${R}\`${B}${1}.deb${R}\`${E} package successfully installed." ) ; } || \
            echol '${R}FAILED to install ${M}${1}${R} package.${E}' '3'
    fi
}
# =[ CUSTOM COMMANDS FUNCTIONS ]==============================================================================
# -[ ADD_CUSTOM_CMD() ]---------------------------------------------------------------------------------------
# Add custom command located at $arg1 named $arg2 
# Exemple: add_custom_cmd "${DOTPATH}/custom_cmds_and_aliases/taskw/get_task_done_by_date.sh" "gtdbd"
add_custom_cmd()
{
    local filepath=${1}
    local cmd_name=${2}
    if command_exists "${cmd_name}";then
        echol "${U}Add custom command:${E} ${G}${cmd_name}${E} is already install." "3"
    else
        create_symlink ${filepath} ${CUSTOM_CMD_BIN_FOLDER}/${cmd_name}
        FINAL_MESSAGE+=("    ${Y}‣${E} ${R}\`${B}${cmd_name}${R}\`${E} custom command successfully installed." )
    fi
}
# -[ SCRIPT_FOUND_AS_CMD ]------------------------------------------------------------------------------------
# Add all bash scripts found in folder as a custom command (using ${CUSTOM_CMD_BIN_FOLDER})
#   - Ex: add_all_script_found_as_cmd "${DOTPATH}/custom_cmds_and_aliases/taskw/"
add_all_script_found_as_cmd()
{
    [[ ${#} -ne 1 ]] && { echol "${R}WRONG USAGE of add_all_script_found_as_cmd, this function take one argument:${M}<path_to_folder>${R} and ${#} arg given${E}" "3" && exit 4 ; }
    if [[ -d ${1} ]];then
        # Check if bin_folder exists, else create it.
        mkdir_if_not_exist "${CUSTOM_CMD_BIN_FOLDER}"
        # Clean bin_folder of broken link
        rm_broken_link_from_folder ${CUSTOM_CMD_BIN_FOLDER}
        # Check if bin_folder in var-env path, else add it by writting in zshrc file.
        [[ ":${PATH}:" != *":${CUSTOM_CMD_BIN_FOLDER}:"* ]] && insert_line_in_file_under_match "export PATH=\"\${PATH}:${CUSTOM_CMD_BIN_FOLDER}\"" "${DOTPATH}/zsh/zshrc" "^.....PATH"
        # Transform script into custom command by creating link inside
        for file in $(find "${1}" -type f -name "*.sh");do add_custom_cmd ${file} $(basename --suffix=".sh" ${file});done
    else
        echol "${U}No custom cmds${E}:'${B}$(short_path ${1})${E}' is not a folder." "3"
    fi
}
# -[ ADD_ALIASES ]--------------------------------------------------------------------------------------------
# Add aliases by creating a syn-link of repo's alias files(filename contains "alias") in ${ACTIVE_ALIASES_FOLDER}
add_aliases()
{
    if [[ ! -d "${ACTIVE_ALIASES_FOLDER}" ]];then
        mkdir_if_not_exist "${ACTIVE_ALIASES_FOLDER}"
        insert_line_in_file_under_match "${ACTIVE_ALIASES_FOLDER##*\/}/" .gitignore
    fi
    create_symlink "${ACTIVE_ALIASES_FOLDER}" "${HOME}/.aliases"
    local folder_name=${1##*\/}
    for file in ${1}/*alias*;do
        local file_name=$(basename "${file}")
        create_symlink "${file}" "${ACTIVE_ALIASES_FOLDER}/${folder_name}_${file_name}"
    done
}
# =[ INSTALL MODULES FUNCTIONS ]==============================================================================
# -[ INSTALL_PRE_REQUIS_CMDS ]--------------------------------------------------------------------------------
# check all needed tools, if not installed, install them
install_pre_requis_cmds()
{
    FINAL_MESSAGE+=("  ${Y}☑ Required Tools${E}" )
    print_title "Required tools."
    echol "${Y}Check all commands/packages needed${E}:"
    install_pck "apt"
    for cmd in "${!PRE_REQUIS_CMDS[@]}";do 
        install_cmd ${cmd} ${PRE_REQUIS_CMDS[${cmd}]}
    done
    print_last
}
# -[ CONFIG_ZSH ]---------------------------------------------------------------------------------------------
config_zsh()
{
    FINAL_MESSAGE+=("  ${Y}☑ ZSH${E}" )
    print_title "ZSH config."
    echol "${Y}Install&Set zsh${E}:"
    install_cmd "zsh"
    local which_zsh=$(which zsh)
    [[ -z "${which_zsh}" ]] && { echol "FAILED to install zsh" && exit 4 ; }
    if [[ "${SHELL}" != "${which_zsh}" ]];then
        sudo usermod -s "${which_zsh}" "$(whoami)" > /dev/null 2>&1 && \
            echol "${G}zsh${E} successfully set as default shell" "3" || \
            { echol "${R}FAILED to set ${B}zsh${R} as default shell" "3" && exit 3 ; }
        FINAL_MESSAGE+=("    ${Y}‣${E} ${R}\`${M}sudo usermod -s ${B}$(which zsh)${R}\`${E} command has been executed successfully during the installation." "    ${Y}⤿${E} But to see changes, you may have to ${U}restart your session.${E} ${B}➪ ${E}${R}\`${M}sudo pkill -u ${B}$(whoami)${E}${R}\`" )
    else
        echol "${G}zsh${E} already set as default shell." "3"
    fi
    
    echol "${Y}Install Oh-my-zsh:${E}"
    if [ -d "${HOME}/.oh-my-zsh" ]; then
        echol "${B}Oh-My-Zsh${E} was already installed." "3"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null 2>&1
        [[ -d ~/.oh-my-zsh ]] && echol "${E}Oh-My-Zsh${E} successfully installed." "3" || echol "${R}FAILED to install ${B}Oh-My-Zsh${R}.${E}" "3"
        FINAL_MESSAGE+=("    ${Y}‣${E} ${R}\`${B}Oh-My-Zsh${R}\`${E} module has been successfully installed." "    ${Y}⤿${E} But to see changes, you may have to ${U}restart your session. ${E}${B}➪ ${E}${R}\`${M}sudo pkill -u ${B}$(whoami)${E}${R}\`" )
    fi

    echol "${Y}Save&Remove old config.:${E}"
    save_file "${HOME}/.zshrc"
    save_folder "${HOME}/.aliases"

    echol "${Y}Set new config.:${E}"
    sed -i "/^export DOTPATH=/c\export DOTPATH=${DOTPATH}" "${DOTPATH}/zsh/zshrc"
    create_symlink "${DOTPATH}/zsh/zshrc" "${HOME}/.zshrc"
    add_aliases ${DOTPATH}/zsh
    print_last
}
# -[ CONFIG_GIT ]---------------------------------------------------------------------------------------------
config_git()
{
    FINAL_MESSAGE+=("  ${Y}☑ GIT${E}" )
    print_title "GIT config."
    echol "${Y}Install commands/packages needed${E}:"
    install_cmd git

    echol "${Y}Save&Remove old config.:${E}"
    save_file "${HOME}/.gitconfig"

    echol "${Y}Set new config.:${E}"
    create_symlink "${DOTPATH}/git/gitconfig" "${HOME}/.gitconfig"
    add_all_script_found_as_cmd "${DOTPATH}/git/custom_cmds"
    add_aliases ${DOTPATH}/git
    print_last
}
# -[ CONFIG_VIM ]---------------------------------------------------------------------------------------------
config_vim()
{
    FINAL_MESSAGE+=("  ${Y}☑ VIM${E}" )
    print_title "VIM config."

    echol "${Y}Install commands/packages needed${E}:"
    install_cmd vim
    install_cmd cscope
    # Check if vim is +clipboard compatible, else install vim-gtk3
    if vim --version | grep -q "+clipboard";then
        echol "${G}vim${E} is clipboard compatible." "3"
    else
        install_cmd vim-gtk3
    fi

    echol "${Y}Save&Remove old config.:${E}"
    save_folder "${HOME}/.vim" "vim_from_home"
    save_file "${HOME}/.vimrc" "vimrc_from_home"
    save_folder "${HOME}/.config/vim" "vim_from_config"

    echol "${Y}Set new config.:${E}"
    create_symlink "${DOTPATH}/vim" "${HOME}/.vim"
    create_symlink "${DOTPATH}/vim/vimrc" "${HOME}/.vimrc"
    echo | vim +PlugInstall +qa > /dev/null 2>&1
    [[ ${?} -eq 0 ]] && echol "Vim plugins installed." "3" || echol "${R}FAILED to install Vim plugins.${E}" "3" 
    add_all_script_found_as_cmd "${DOTPATH}/vim/custom_cmds"
    add_aliases ${DOTPATH}/vim
    print_last
}
# -[ CONFIG_TASK ]--------------------------------------------------------------------------------------------
config_taskw()
{
    FINAL_MESSAGE+=("  ${Y}☑ Task&Time-Warrior${E}" )
    print_title "TASKWARRIOR config."
    
    echol "${Y}Install commands/packages needed${E}:"
    install_cmd task taskwarrior
    install_cmd timew timewarrior
    # TODO add taskserveur (client & serveur)
    
    echol "${Y}Save&Remove old config.:${E}"
    save_folder "${HOME}/.task" "task_from_home"
    save_file "${HOME}/.taskrc" "taskrc_from_home"
    save_folder "${HOME}/.config/task" "task_from_config"

    echol "${Y}Set new config.:${E}"
    create_symlink ${DOTPATH}/task ${HOME}/.config/task
    create_symlink ${DOTPATH}/task/taskrc ${HOME}/.taskrc
    add_all_script_found_as_cmd ${DOTPATH}/task/custom_cmds
    add_aliases ${DOTPATH}/task
    print_last
}
# -[ INSTALL OTHER TOOLS ]------------------------------------------------------------------------------------
install_other_tools()
{
    FINAL_MESSAGE+=("  ${Y}☑ Other Tools&Projects${E}" )
    print_title "Install Other Project/Tools:"

    echol "${Y}WikiLinkConvertor as ${G}wlc${E} command:${E}"
    add_all_script_found_as_cmd "${DOTPATH}/wlc"

    echol "${Y}Install usefull commands:${E}"
    install_cmd "tree"

    print_last
}
# -[ INSTALL GNOME TERMINAL ]---------------------------------------------------------------------------------
config_desk_env()
{
    # GNOME
    if [[ "${XDG_CURRENT_DESKTOP}" =~ GNOME|Unity|XFCE ]]; then
        FINAL_MESSAGE+=("  ${Y}☑ Gnome Desktop Env.${E}" )
        print_title "Configure GNOME Desktop Environnement:"

        echol "${Y}Gnome config. tools:${E}"
        install_cmd dconf dconf-editor
        install_cmd fc-list fontconfig
        install_cmd gnome-terminal

        echol "${Y}Gnome install fonts:${E}"
        local user_font_dir="${HOME}/.local/share/fonts"
        mkdir_if_not_exist ${user_font_dir}
        rm_broken_link_from_folder ${user_font_dir}
        for font in "${DOTPATH}/desk-env/fonts/"*;do 
            create_symlink ${font} ${user_font_dir}/${font##*\/}
        done

        echol "${Y}Configure Gnome-Terminal:${E}"
        local gnome_terminal_profile_file=$(ls ${DOTPATH}/desk-env/gnome/*.dconf)
        local gnome_terminal_profil_ID=${gnome_terminal_profile_file##*\/}
        local gnome_terminal_profil_ID=${gnome_terminal_profil_ID%\.*}
        dconf load "/org/gnome/terminal/legacy/profiles:/:${gnome_terminal_profil_ID}/" < "${gnome_terminal_profile_file}" && \
            { echol "${B}$(short_path ${gnome_terminal_profile_file})${E} file successfully import." "3" && FINAL_MESSAGE+=("    ${Y}‣${E} ${B}Gnome-Terminal${E} app. has been successfully configured." "    ${Y}⤿${E} If its font has been changed and looks weird...to fix it you have to ${U}restart your gnome-terminal.${E}" ) ; } || \
            echol "${R}FAILED import gnome_terminal_profile_file ${B}$(short_path ${gnome_terminal_profile_file})${E}." "3"
    else
        print_title "Configure Unknown Desktop Environnement:"
        echol "${R}This desktop environnement not handle for now:${E}"
    fi
    print_last
}
# ============================================================================================================
# MAIN
# ============================================================================================================
if command_exists "dpkg";then
    sudo -v #Start by enter once for all the password
    install_pre_requis_cmds
    config_zsh
    config_git
    config_vim
    config_taskw
    install_other_tools
    config_desk_env
    print_in_box -t 1 -c by "${FINAL_MESSAGE[@]}"
    sudo -k #Kill the period of time where password not needed.
else
    echo "${R}This installation script works only on debian or Debian-based systems for now!${E}"
fi
