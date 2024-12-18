#!/usr/bin/env bash

# ============================================================================================================
# INSTALL SCRIPT
# install my conf.: make backup folder with actual dotfiles before replacing them with sym-links to my dotfiles
# - after `git clone https://github.com/alterGNU/Dotfiles.git` just do `./Dorfiles/install.sh`
# - with curl : `sh -c "$(curl -fsSL https://raw.githubusercontent.com/alterGNU/Dotfiles/refs/heads/main/install.sh)`
# PRE-REQUIS
# - Dotfiles submodules uptodate :`git clone --recurse-submodules -j8 git@github.com:alterGNU/Dotfiles.git`
# - zsh already install (Oh my zsh too)
#
# GOOD-TO-KNOW
# - Dotfiles project can be clone anywhere, this script will create symbolic-links so that the dotfiles work.
# - VAR-ENV : DOTPATH (set at "" by default), is the path to the Dotfiles folder
#
# TODO :
#   - [ ] Create func add_cmd_folder that take only a folder that contains fun/script and exec add_custom_cmd automatically (filename - ext = cmd name)
#   - [ ] Add Dotfiles/custom_cmds_and_aliases/git/* 
#   - [ ] Add taskserver package and config file (server & client)
#   - [ ] Usemode with git-clone (no git clone needed)
#   - [ ] Usemode with curl or wget (need to git clone recursive submodule:vim,...)
#   - [ ] Add interactive argument (ask user before each step if install needed/wanted)
#   - [ ] Add uninstall that also remove CUSTOM_CMD_BIN_FOLDER (solve link, if dead, rm sym-link)
# ============================================================================================================
 
# ============================================================================================================
# VAR
# ============================================================================================================
# =[ PRE_REQUIS_CMDS ]========================================================================================
# Commands needed key=cmd_name value=package to install
# coreutils = tee, date, direname, realpath , mktemp, whoami
declare -A PRE_REQUIS_CMDS=( \
    ["curl"]="curl" \
    ["find"]="findutils" \
    ["grep"]="grep" \
    ["sed"]="sed" \
    ["tee"]="coreutils" \
    ["usermod"]="passwd" \
    ["which"]="which" \
    ["xsel"]="xsel" \
)
# =[ PATH ]===================================================================================================
LEN=110                                                  # Textwidth
BCK="${HOME}/backups"                                    # Path of the backup folder
FLD="${BCK}/$(date +%Y_%m_%d.%Hh%Mm%Ss)"                 # Name of the backup folder
DOTPATH=$(dirname $(realpath ${0}))                      # Path of the Dotfile folder
# =[ FOLDERS ]================================================================================================
CUSTOM_CMD_BIN_FOLDER="${HOME}/.local/bin"               # Folder where bin/custom cmd link are store (add to PATH ENV-VAR.)
ACTIVE_ALIASES_FOLDER="${DOTPATH}/active_custom_aliases" # Folder where actives aliases files are store (source in zshrc)
# =[ COLORS ]=================================================================================================
R="\033[1;31m"                                           # START RED
G="\033[1;32m"                                           # START GREEN
M="\033[1;33m"                                           # START BROWN
U="\033[4;29m"                                           # START UNDERSCORED
B="\033[1;36m"                                           # START BLUE
Y="\033[0;93m"                                           # START YELLOW
YY="\033[5;93m"                                           # START YELLOW
# Commands needed
BB="\033[1;96m"                                          # START BLUE
E="\033[0m"                                              # END color balise
# =[ BOX ]====================================================================================================
  H="═"                                                  # Horizontal
  V="║"                                                  # Vertical
 VS="╠"                                                  # Vertical Split
TLC="╔"                                                  # Top Left Corner
TRC="╗"                                                  # Top Right Corner
BLC="╚"                                                  # Bottom Left Corner
BRC="╝"                                                  # Bottom Right Corner

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
        echol "${U}rm sym-link${E}: '${BB}$(short_path ${1})${E}' ➟  '${M}$(short_path ${solved_link})${E}'" "3"
    fi
}
# -[ CREATE SYM-LINK ]----------------------------------------------------------------------------------------
# create a sym-link from arg1 to arg2 (if arg2 already exists, do nothing)
create_symlink()
{
    if [[ -L "${2}" ]];then
        local old_link=$(readlink -f "${1}")
        if [[ "${old_link}" == "${1}" ]];then
            echol "${U}Link already exist${E}: '${BB}$(short_path ${2})${E}' ➟ '${M}$(short_path ${1})${E}'" "3"
        else
            echol "${U}Link already exist${E}: '${BB}$(short_path ${2})${E}' ${R}↛${E} '${M}$(short_path ${1})${E}'" "3"
            echol "                                            ${G}⮡${E} '${M}${old_link}${E}'" "3"
        fi
    else
        ln -s "${1}" "${2}" && echol "${U}Create sym-link${E}: '${BB}$(short_path ${2})${E}' ➟ '${M}$(short_path ${1})${E}'" "3" || { echol "${R}FAILED to create sym-link: '${BB}$(short_path ${2})${R}' ➟ '${M}$(short_path ${1})${E}'" "3" && exit 3 ; }
        if ! is_a_valid_symlink "${2}";then
            echol "${R}Sym-link created not valid:'${BB}$(short_path ${2})${R}' ➟ '${M}$(short_path ${1})${E}'" "5"
            rm "${2}" && echol "${R}Sym-link '${BB}$(short_path ${2})${R}' REMOVED!" "5"
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
    echo -en "${TLC}" && pnt ${H} $(( size + 1 )) && echo -en "${TRC}\n"
    echo -en "${V} ${titre} ${VS}" && pnt "${H}" $((LEN - $(get_len "${titre}") - 5 )) && echo -en "${TRC}\n"
    echo -en "${VS}" && pnt ${H} $(( size + 1 )) && echo -en "${BRC}"
    pnt "\x20" $((LEN - $(get_len "${titre}") - 5 )) && echo -en "${V}\n"
}
print_last() { echo -en "${BLC}" && pnt ${H} $(( LEN - 2 )) && echo -en "${BRC}\n" ; }
# -[ ECHO LINE ]----------------------------------------------------------------------------------------------
# echo line inside the box (arg2 optionnal=indentation with custom. list items symb.)
echol()
{
    local sym=( "${Y}✦${E}" "${Y}➣${E}" "${Y}➣${E}"  "${Y}⤷${E}" "${Y}⤷${E}" "${Y}⤷${E}" "${Y}⤷${E}" )
    [[ ${#} -eq 1 ]] && local indent=1 || local indent=${2}
    local sym=${sym[$(((${indent} % ${#sym[@]})-1))]}
    local spaces=$(printf ' %.s' $(seq 1 ${indent}))
    local line="${V}${spaces}${B}${sym}${E} ${1}"
    local size=$(get_len "${line}")
    echo -en "${line}"
    pnt "\x20" $(( LEN - size - 1 ))
    [[ ${LEN} -gt $(( size + 1 )) ]] && echo -en "${V}\n" || echo -en "\n"
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
        if [[ -n ${3} ]] && grep -q "${3}" "${2}";then
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
        for frame in "${frames[@]}"; do echo -en "${V} " && printf "${frame}\r" && sleep ${delay} ; done
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
        sudo apt-get install -y "${pck_name}" > /dev/null 2>&1 && \
        echol "pck ${B}${pck_name}${E} successfully installed." "3" || \
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
            echol 'pck ${B}${1}.deb${E} installed successfully' '3' || \
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
        [[ ":${PATH}:" != *":${CUSTOM_CMD_BIN_FOLDER}:"* ]] && insert_line_in_file_under_match "export PATH=\"\${PATH}:\${CUSTOM_CMD_BIN_FOLDER}\"" "${DOTPATH}/zsh/zshrc" "# -[ PATH ]---------------------------------------------------------------------------------------------------"
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
        echo "${ACTIVE_ALIASES_FOLDER##*\/}/" >> .gitignore
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
    print_title "Required tools."
    echol "${Y}Check all commands/packages needed${E}:"
    install_pck "apt"
    for cmd in "${!PRE_REQUIS_CMDS[@]}";do 
        exec_anim "install_cmd ${cmd} ${PRE_REQUIS_CMDS[${cmd}]}" ; done
    print_last
}
# -[ CONFIG_ZSH ]---------------------------------------------------------------------------------------------
config_zsh()
{
    print_title "ZSH config."
    echol "${Y}Install&Set zsh${E}:"
    install_cmd "zsh"
    local which_zsh=$(which zsh)
    [[ -z "${which_zsh}" ]] && { echol "FAILED to install zsh" && exit 4 ; }
    if [[ "${SHELL}" != "${which_zsh}" ]];then
        sudo usermod -s "${which_zsh}" "$(whoami)" > /dev/null 2>&1 && \
            echol "${G}zsh${E} successfully set as default shell" "3" || \
            { echol "${R}FAILED to set ${B}zsh${R} as default shell" "3" && exit 3 ; }
    else
        echol "${G}zsh${E} already set as default shell." "3"
    fi
    
    echol "${Y}Install Oh-my-zsh:${E}"
    if [ -d "${HOME}/.oh-my-zsh" ]; then
        echol "${B}Oh-My-Zsh${E} was already installed." "3"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null 2>&1
        [[ -d ~/.oh-my-zsh ]] && echol "${E}Oh-My-Zsh${E} successfully installed." "3" || echol "${R}FAILED to install ${B}Oh-My-Zsh${R}.${E}" "3"
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
    print_title "GIT config."
    echol "${Y}Install commands/packages needed${E}:"
    exec_anim "install_cmd git"

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
    print_title "VIM config."

    echol "${Y}Install commands/packages needed${E}:"
    exec_anim "install_cmd vim"
    exec_anim "install_cmd cscope"
    # Check if vim is +clipboard compatible, else install vim-gtk3
    if vim --version | grep -q "+clipboard";then
        echol "${G}vim${E} is clipboard compatible." "3"
    else
        exec_anim "install_cmd vim-gtk3"
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
    print_title "TASKWARRIOR config."
    
    echol "${Y}Install commands/packages needed${E}:"
    exec_anim "install_cmd task taskwarrior"
    exec_anim "install_cmd timew timewarrior"
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
    print_title "Install Other Project/Tools:"

    echol "${Y}WikiLinkConvertor as ${G}wlc${E} command:${E}"
    add_all_script_found_as_cmd "${DOTPATH}/wlc"

    print_last
}
# -[ INSTALL GNOME TERMINAL ]---------------------------------------------------------------------------------
config_desk_env()
{
    # GNOME
    if [[ "${XDG_CURRENT_DESKTOP}" =~ GNOME|Unity|XFCE ]]; then
        print_title "Configure GNOME Desktop Environnement:"

        echol "${Y}Gnome config. tools:${E}"
        exec_anim "install_cmd dconf dconf-editor"
        exec_anim "install_cmd fc-list fontconfig"
        exec_anim "install_cmd gnome-terminal"

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
            echol "${B}$(short_path ${gnome_terminal_profile_file})${E} file successfully import." "3" || \
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
    echo -e "${YY}To see all the changes in effect, exit and re-enter the terminal.${E}"
    sudo -k #Kill the period of time where password not needed.
else
    echo "${R}This installation script works only on debian or Debian-based systems for now!${E}"
fi
