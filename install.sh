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
#   - [ ] Add pre-requis test (zsh + oh-my-zsh + vim + git) cf Ubuntu_install install script
#   - [ ] Usemode with git-clone (no git clone needed)
#   - [ ] Usemode with curl or wget (need to git clone recursive submodule:vim,...)
#   - [ ] Add interactive argument (ask user before each step if install needed/wanted)
#   - [X] Add step print (start install chapter:zshrc , vim, git , etc)
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
R="\033[1;31m"                                   # START RED
G="\033[1;32m"                                   # START GREEN
M="\033[1;33m"                                   # START BROWN
U="\033[4;29m"                                   # START UNDERSCORED
B="\033[1;36m"                                   # START BLUE
BB="\033[1;96m"                                  # START BLUE
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
del_symlink()
{ 
    if [[ -h "${1}" ]];then
        local solved_link=$(readlink -f "${1}")
        rm "${1}"
        echol "${U}rm sym-link${E}: '${BB}${1}${E}' ➟  '${M}${solved_link}${E}'"
    fi
}
# -[ CREATE_BCKUP_FOLDER() ]----------------------------------------------------------------------------------
# create a backup folder if not already created
create_bckup_folder() { [[ ! -d ${FLD}/${1} ]] && mkdir -p ${FLD}/${1} ; }
# -[ CREATE SYN-LINK ]----------------------------------------------------------------------------------------
# create a sym-link from arg1 to arg2
create_symlink() { ln -s ${1} ${2} && echol "${U}Create sym-link${E}: '${BB}${2}${E}' ➟ '${M}${1}${E}'" ; }
# -[ SAVE_FILE ]----------------------------------------------------------------------------------------------
# If arg1 is a path to a file, make a backup. The backup name can be manually provide by arg2 (opt)
save_file()
{
    del_symlink "${1}"
    if [[ -f "${1}" ]];then
        create_bckup_folder
        [[ -n "${2}" ]] && local dst_filename="${2}" || local dst_filename=$(basename "${1}")
        mv "${1}" "${FLD}/${dst_filename}" && echol "${U}Create backup-file${E}: '${FLD}/${dst_filename}'"
    fi
}
# -[ SAVE_FOLDER ]--------------------------------------------------------------------------------------------
# If arg1 is a path to a folder, make a backup. The backup name can be manually provide by arg2 (opt)
save_folder()
{
    del_symlink "${1}"
    if [[ -f "${1}" ]];then
        create_bckup_folder
        [[ -n "${2}" ]] && local dst_foldername="${2}" || local dst_foldername=$(basename "${1}")
        mv "${1}" "${FLD}/${dst_foldername}" && echol "${U}Create backup-folder${E}:'${FLD}/${dst_foldername}'"
    fi
}
# -[ IS_INSTALLED ]-------------------------------------------------------------------------------------------
# Check if a command is installed
command_exists(){ command -v "${1}" > /dev/null 2>&1 ; }

# -[ INSTALL_STEP ]-------------------------------------------------------------------------------------------
# install step : arg1=step title displayed arg2=install function name.
install_step()
{
    print_title "${1}"
    ${2}
    print_last
}
# =[ CONFIG-FCTS ]============================================================================================
# -[ CONFIG_ZSH ]---------------------------------------------------------------------------------------------
config_zsh()
{
    print_title "${B}ZSH config.${E}"
    # check if zsh is installed, else install it
    if command_exists "zsh";then
        echol "${G}zsh${E} was already installed"
    else
        exec_anim "sudo apt install -y zsh"
        echol "${G}zsh${E} installed."
    fi
    # check if oh-my-zsh is installed, else install it
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echol "${B}Oh-My-Zsh${E} was already installed."
    else
        exec_anim 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
        echol "${E}Oh-My-Zsh${E} installed."
    fi
    # Set zsh the default shell
    if [ "${SHELL}" != "$(command -v zsh)" ]; then
        chsh -s "$(command -v zsh)" && echol "${G}zsh${E} successfully set as default shell." || echol "zsh wasn't set as default shell"
    else
        echol "${G}zsh${E} was already the default shell."
    fi
    # Add real $DOTPATH value in zshrc + save old dotfiles + create link
    sed -i "/^export DOTPATH=/c\export DOTPATH=${DOTPATH}" ${DOTPATH}/zshrc
    save_file "${HOME}/.zshrc"
    create_symlink "${DOTPATH}/zshrc" "${HOME}/.zshrc"
    print_last
}
# -[ CONFIG_GIT ]---------------------------------------------------------------------------------------------
config_git()
{
    print_title "${B}GIT config.${E}"
    # check if git is installed, else install it
    if command_exists "git";then
        echol "${G}git${E} is already installed."
    else
        exec_anim "sudo apt install git"
        echol "${G}git${E} successfully installed."
    fi
    # Make save old dotfiles + Create symlink to gitconfig file
    save_file "${HOME}/.gitconfig"
    create_symlink ${DOTPATH}/gitconfig ${HOME}/.gitconfig
    # TODO All custom git command
    print_last
}
# -[ CONFIG_VIM ]---------------------------------------------------------------------------------------------
config_vim()
{
    print_title "${B}VIM config.${E}"
    # check if vim is installed, else install it
    if command_exists "vim";then
        echol "${G}vim${E} was already installed."
    else
        exec_anim "sudo apt install vim"
        echol "${G}vim${E} installed."
    fi
    # Check if vim is +clipboard compatible, else install vim-gtk3
    if vim --version | grep -q "+clipboard";then
        echol "${G}vim${E} is clipboard compatible."
    else
        exec_anim "sudo apt install -y vim-gtk3"
        echol "${B}vim-gtk3${E} package successfully installed."
    fi
    #Check if cscope installed, else install cscope
    if command_exists "cscope";then
        echol "${G}cscope${E} was already installed."
    else
        exec_anim "sudo apt install cscope"
        echol "${G}cscope${E} was successfully installed."
    fi
    # Save old dotfiles + create synlinks to ~/.vim/ and ~/.vimrc then install vim plugin
    save_folder "${HOME}/.vim" "vim_from_home"
    save_file "${HOME}/.vimrc" "vimrc_from_home"
    save_folder "${HOME}/.config/vim" "vim_from_config"
    create_symlink ${DOTPATH}/vim ${HOME}/.vim
    create_symlink ${DOTPATH}/vim/vimrc ${HOME}/.vimrc
    exec_anim "vim -es -c 'PlugInstall' -c 'PlugUpdate' -c 'qa'"
    echol "Vim plugin installed."
    print_last
}
# -[ CONFIG_TASK ]--------------------------------------------------------------------------------------------
config_taskw()
{
    print_title "${B}TASKWARRIOR config.${E}"
    # Check if task installed, else install cscope
    if command_exists "task";then
        echol "${G}taskwarrior${E} was already installed."
    else
        exec_anim "sudo apt install taskwarrior"
        echol "${G}taskwarrior${E} was successfully installed."
    fi
    # TODO configure taskd
    # Check if timewarrior installed, else install timewarrior
    if command_exists "timew";then
        echol "${G}timewarrior${E} was already installed."
    else
        exec_anim "sudo apt install timewarrior"
        echol "${G}timewarrior${E} was successfully installed."
    fi
    # Save old dotfile and create link
    save_folder "${HOME}/.task/hook" "taskhook_from_home"
    save_file "${HOME}/.taskrc" "taskrc_from_home"
    save_folder "${HOME}/.config/task" "task_from_config"
    create_symlink ${DOTPATH}/task ${HOME}/.config/task
    create_symlink ${DOTPATH}/task/taskrc ${HOME}/.taskrc
    # Install custom command
    if command_exists "get_task_done_by_date";then
        echol "Custom command: ${G}get_task_done_by_date${E} is already install."
    else
        [[ ! -d "${HOME}/.local/bin" ]] && mkdir -p "${HOME}/.local/bin"
        create_symlink ${DOTPATH}/cmds/taskw/get_task_done_by_date.sh ${HOME}/.local/bin/get_task_done_by_date
        echol "Custom command: ${G}get_task_done_by_date${E} was successfully installed."
    fi
    print_last
}
# -[ INSTALL_CUSTOM_CMD_WLC ]---------------------------------------------------------------------------------
install_other_custom_cmd()
{
    print_title "${B}Other Custom Commands:${E}"
    if command_exists "wlc";then
        echol "${G}wlc${E} is already install."
    else
        [[ ! -d "${HOME}/.local/bin" ]] && mkdir -p "${HOME}/.local/bin"
        create_symlink ${DOTPATH}/cmds/WLC/wlc.sh ${HOME}/.local/bin/wlc
        echol "${G}wlc${E} was successfully installed."
    fi
    print_last
}
# ============================================================================================================
# MAIN
# ============================================================================================================
config_zsh
config_git
config_vim
config_taskw
install_other_custom_cmd
