#!/usr/bin/env bash

# ============================================================================================================
# INSTALL SCRIPT
# install my conf.: make backup folder with actual dotfiles before replacing them with sym-links to my dotfiles
# - after `git clone https://github.com/alterGNU/Dotfiles.git` just do `./Dorfiles/install.sh`
# - with curl : `sh -c "$(curl -fsSL https://raw.githubusercontent.com/alterGNU/Dotfiles/refs/heads/main/install.sh)`
# - with wget : `sh -c "$(wget -qO- https://raw.githubusercontent.com/alterGNU/Dotfiles/refs/heads/main/install.sh)`
# - with fetch: `sh -c "$(fetch -o - https://raw.githubusercontent.com/alterGNU/Dotfiles/refs/heads/main/install.sh)`
# 
# PRE-REQUIS
# - Dotfiles submodules uptodate :`git clone --recurse-submodules -j8 git@github.com:alterGNU/Dotfiles.git`
# - zsh already install (Oh my zsh too)
#
# GOOD-TO-KNOW
# - Dotfiles project can be clone anywhere, this script will create symbolic-links so that the dotfiles work.
# - VAR-ENV : DOTPATH (set at "" by default), is the path to the Dotfiles folder
#
# TODO :
# - [ ] Add pre-requis test (zsh + oh-my-zsh + vim + git) cf Ubuntu_install install script
# - [ ] Usemode with git-clone (no git clone needed)
# - [ ] Usemode with curl or wget (need to git clone recursive submodule:vim,...)
# - [ ] Add interactive argument (ask user before each step if install needed/wanted)
# - [X] Add step print (start install chapter:zshrc , vim, git , etc)
# ============================================================================================================
 
# ============================================================================================================
# VAR
# ============================================================================================================
# =[ PATH ]===================================================================================================
LEN=110                                          # Textwidth
BCK="${HOME}/backups"                            # Path of the backup folder
FLD="${BCK}/$(date +%Y_%m_%d.%Hh%Mm%Ss)"         # Name of the backup folder
DOTPATH=$(dirname $(realpath ${0}))              # Path of the Dotfile folder
# =[ COLORS ]=================================================================================================
R="\033[0;31m"                                   # START RED
G="\033[0;32m"                                   # START GREEN
M="\033[0;33m"                                   # START BROWN
Y="\033[0;93m"                                   # START YELLOW
B="\033[0;36m"                                   # START BLUE
E="\033[0m"                                      # END color balise
# =[ BOX ]====================================================================================================
  H="═"                                          # Horizontal
  V="║"                                          # Vertical
 VS="╠"                                          # Vertical Split
TLC="╔"                                          # Top Left Corner
TRC="╗"                                          # Top Right Corner
BLC="╚"                                          # Bottom Left Corner
BRC="╝"                                          # Bottom Right Corner

# ============================================================================================================
# FUNCTIONS
# ============================================================================================================
# =[ UTILS FCTS ]=============================================================================================
# -[ GET_LEN ]------------------------------------------------------------------------------------------------
# return real len
get_len() { echo $(echo -en "${1}" | sed 's/\x1b\[[0-9;]*m//g' | wc -m) ; }
# -[ PRINT N TIMES ]------------------------------------------------------------------------------------------
# print SEP LEN times
pnt() { for i in $(seq 0 $((${2})));do echo -en ${1};done ; }
# -[ PRINT_TITLE ]--------------------------------------------------------------------------------------------
print_title()
{
    local size=$(get_len "${1}")
    echo -en "${TLC}" && pnt ${H} $(( size + 1 )) && echo -en "${TRC}\n"
    echo -en "${V} ${1} ${VS}" && pnt "${H}" $((LEN - $(get_len "${1}") - 5 )) && echo -en "${TRC}\n"
    echo -en "${VS}" && pnt ${H} $(( size + 1 )) && echo -en "${BRC}"
    pnt "\x20" $((LEN - $(get_len "${1}") - 5 )) && echo -en "${V}\n"
}
print_last() { echo -en "${BLC}" && pnt ${H} $(( LEN - 2 )) && echo -en "${BRC}\n" ; }
# -[ ECHO LINE ]----------------------------------------------------------------------------------------------
# echo line
echol()
{
    local line="${V} ${B}‣${E} ${1}"
    local size=$(get_len "${line}")
    echo -en "${line}"
    pnt "\x20" $(( LEN - size - 1 ))
    [[ ${LEN} -gt $(( size + 1 )) ]] && echo -en "${V}\n" || echo -en "\n"
}
# -[ EXEC_ANIM() ]--------------------------------------------------------------------------------------------
# print animation in frontground while cmd exec in background the print returns.
exec_anim()
{
    local frames=( 🕛  🕒  🕕  🕘 )
    local delay=0.1 
    local cmd="${@}"
    local tmpfile=$(mktemp "${TMPDIR:-/tmp}/exec_anim_${cmd%% *}_XXXXXX")
    trap '[[ -f "${tmpfile}" ]] && rm -f "${tmpfile}"' EXIT RETURN
    ${cmd} > "${tmpfile}" 2>&1 &
    local pid=${!}
    while kill -0 ${pid} 2>/dev/null; do
        for frame in "${frames[@]}"; do echo -en "${V} " && printf "${frame}\r" && sleep ${delay} ; done
    done
    printf "\r" && wait ${pid}
    local exit_code=${?}
    printf "\r" && cat "${tmpfile}"
    return ${exit_code}
}
# -[ DEL_SYMLINK ]--------------------------------------------------------------------------------------------
# If arg1 is a path to a synbolic link, delete it
del_symlink() { [[ -h "${1}" ]] && rm "${1}" ; }
# -[ CREATE_BCKUP_FOLDER() ]----------------------------------------------------------------------------------
# create a backup folder if not already created
create_bckup_folder() { [[ ! -d ${FLD}/${1} ]] && mkdir -p ${FLD}/${1} ; }
# -[ CREATE SYN-LINK ]----------------------------------------------------------------------------------------
# create a sym-link from arg1 to arg2
create_symlink() { ln -s ${1} ${2} && echol "create sym-link '${B}${2}${E}' ➟ '${M}${1}${E}'" ; }
# -[ SAVE_FILE ]----------------------------------------------------------------------------------------------
# If arg1 is a path to a file, make a backup. The backup name can be manually provide by arg2 (opt)
save_file()
{
    if [[ -h "${1}" ]];then
        rm ${1} && echol "rm sym-link '${1}'"
    elif [[ -f "${1}" ]];then
        create_bckup_file
        [[ -n "${2}" ]] && local dst_filename="${2}" || local dst_filename=$(basename "${1}")
        mv "${1}" "${FLD}/${dst_filename}" && echol " - Create backup-file:'${FLD}/${dst_filename}'"
    fi
}
# -[ SAVE_FOLDER ]--------------------------------------------------------------------------------------------
# If arg1 is a path to a folder, make a backup. The backup name can be manually provide by arg2 (opt)
save_folder()
{
    if [[ -h "${1}" ]];then
        rm ${1} && echol "rm sym-link '${1}'"
    elif [[ -f "${1}" ]];then
        create_bckup_folder
        [[ -n "${2}" ]] && local dst_foldername="${2}" || local dst_foldername=$(basename "${1}")
        mv "${1}" "${FLD}/${dst_foldername}" && echol " - Create backup-folder:'${FLD}/${dst_foldername}'"
    fi
}
# -[ INSTALL_STEP ]-------------------------------------------------------------------------------------------
# install step : arg1=step title displayed arg2=install function name.
install_step()
{
    print_title "${1}"
    exec_anim "${2}"
    print_last
}
# =[ CONFIG-FCTS ]============================================================================================
# -[ CONFIG_ZSH ]---------------------------------------------------------------------------------------------
config_zsh()
{
    sed -i "/^export DOTPATH=/c\export DOTPATH=${DOTPATH}" ${DOTPATH}/zshrc
    save_file "${HOME}/.zshrc"
    create_symlink "${DOTPATH}/zshrc" "${HOME}/.zshrc"
}
# -[ CONFIG_GIT ]---------------------------------------------------------------------------------------------
config_git()
{
    save_file "${HOME}/.gitconfig"
    create_symlink ${DOTPATH}/gitconfig ${HOME}/.gitconfig
}
# -[ CONFIG_VIM ]---------------------------------------------------------------------------------------------
config_vim()
{
    save_folder "${HOME}/.vim" "vim_from_home"
    save_file "${HOME}/.vimrc" "vimrc_from_home"
    save_folder "${HOME}/.config/vim" "vim_from_config"
    create_symlink ${DOTPATH}/vim ${HOME}/.vim
    create_symlink ${DOTPATH}/vim/vimrc ${HOME}/.vimrc
    echo -e "\n" | vim -c "PlugInstall" -c "qa" > /dev/null 2>&1
    echo -e "\n" | vim -c "PlugUpdate" -c "qa" > /dev/null 2>&1
}
# -[ CONFIG_TASK ]--------------------------------------------------------------------------------------------
config_taskw()
{
    save_folder "${HOME}/.task/hook" "taskhook_from_home"
    save_file "${HOME}/.taskrc" "taskrc_from_home"
    save_folder "${HOME}/.config/task" "task_from_config"
    create_symlink ${DOTPATH}/task ${HOME}/.config/task
    create_symlink ${DOTPATH}/task/taskrc ${HOME}/.taskrc
}
# -[ INSTALL_CUSTOM_CMD_WLC ]---------------------------------------------------------------------------------
install_custom_cmd_wlc()
{
    local found=$(command -v wlc 2>&1 >/dev/null && echo no || echo yes)
    if [[ "${found}" == "yes" ]];then
        [[ ! -d "${HOME}/.local/bin" ]] && mkdir -p "${HOME}/.local/bin"
        create_symlink ${DOTPATH}/cmds/WLC/wlc.sh ${HOME}/.local/bin/wlc
    else
        echol "A command named '${R}wlc${E}' already exists:${M}$(which wlc)${E}"
    fi
}
# ============================================================================================================
# MAIN
# ============================================================================================================
install_step "${B}ZSH config.${E}" "config_zsh"
install_step "${B}GIT config.${E}" "config_git"
install_step "${B}VIM config.${E}" "config_vim"
install_step "${B}TASKWARRIOR config.${E}" "config_taskw"
install_step "${B}Custom Command: wlc${E}" "install_custom_cmd_wlc"
