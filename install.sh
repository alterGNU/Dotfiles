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
#   - [ ] Add Dotfiles/cmds/git/* 
#   - [ ] Add taskserver package and config file (server & client)
#   - [ ] Usemode with git-clone (no git clone needed)
#   - [ ] Usemode with curl or wget (need to git clone recursive submodule:vim,...)
#   - [ ] Add interactive argument (ask user before each step if install needed/wanted)
# ============================================================================================================
 
# ============================================================================================================
# VAR
# ============================================================================================================
# Commands needed
PRE_REQUIS_CMDS=( "curl" )
# Bin Folder to add to PATH ENV-VAR.
BINPATH="${HOME}/.local/bin"
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
# Commands needed
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
create_symlink()
{
    ln -s ${1} ${2} 
    if [[ ${?} -eq 0 ]];then
        echol "${U}Create sym-link${E}: '${BB}${2}${E}' ➟ '${M}${1}${E}'"
    else
        echol "${R}Something went wrong while creating sym-link: '${BB}${2}${R}' ➟ '${M}${1}${E}'"
        return 3;
    fi
}
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
# -[ COMMAND_EXISTS ]-----------------------------------------------------------------------------------------
# Check if a command is installed
command_exists(){ command -v "${1}" > /dev/null 2>&1 ; }
# -[ INSTALL_CMD ]--------------------------------------------------------------------------------------------
# Check if command is installed, else install it
install_cmd()
{
    local cmd_name=${1}
    [[ -z ${2} ]] && local pck_name=${1} || local pck_name=${2}
    if command_exists "${cmd_name}";then
        echol "${G}${pck_name}${E} already installed."
    else
        exec_anim "yes | sudo apt install ${pck_name}"
        echol "${G}${pck_name}${E} installed successfully."
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
        echol "${G}${1}${E} package already installed."
    else
        exec_anim "pkexec dpkg -i ${1}.deb && echol '${G}${1}.deb${E} installed successfully' || echol '${R}Can not install ${M}${1}${R} package. Something want wrong${E}'"
    fi
}
# -[ ADD_CUSTOM_CMD() ]---------------------------------------------------------------------------------------
# Add custom command located at $arg1 named $arg2
add_custom_cmd()
{
    local filepath=${1}
    local cmd_name=${2}
    if command_exists "${cmd_name}";then
        echol "${U}Custom command:${E} ${G}${cmd_name}${E} is already install."
    else
        [[ ! -d "${BINPATH}" ]] && mkdir -p "${BINPATH}"
        create_symlink ${filepath} ${BINPATH}/${cmd_name}
    fi
}
# =[ CONFIG-FCTS ]============================================================================================
# -[ install_pre_requis_cmds ]--------------------------------------------------------------------------------------------
# check all needed tools, if not installed, install them
install_pre_requis_cmds()
{
    print_title "${B}Install required tools.${E}"
    # Install apt if not already here
    install_pck "apt"
    for pkg in ${PRE_REQUIS_CMDS[@]};do exec_anim "install_cmd ${pkg}" ; done
    print_last
}
# -[ CONFIG_ZSH ]---------------------------------------------------------------------------------------------
config_zsh()
{
    print_title "${B}ZSH config.${E}"
    # install zsh if not already installed
    install_cmd "zsh"
    # set zsh as default shell if not already
    if [[ "${SHELL}" != "$(which zsh)" ]];then
        chsh -s $(which zsh) && echol "Zsh successfully set as default shell" || { echol "${R}Something went wrong will setting Zsh as default shell" && exit 3 ; }
    else
        echol "Zsh already set as default shell."
    fi
    # check if oh-my-zsh is installed, else install it
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echol "${B}Oh-My-Zsh${E} was already installed."
    else
        exec_anim 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended'
        [[ ${?} -eq 0 ]] && echol "${E}Oh-My-Zsh${E} installed." || echol "${R}Something went wrong will downloading Oh-My-Zsh.${E}"
    fi
    # Set zsh the default shell
    if [ "${SHELL}" != "$(which zsh)" ]; then
        exec $(which zsh)
    else
        echol "Already on zsh."
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
    exec_anim "install_cmd git"
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
    exec_anim "install_cmd vim"
    exec_anim "install_cmd cscope"
    # Check if vim is +clipboard compatible, else install vim-gtk3
    if vim --version | grep -q "+clipboard";then
        echol "${G}vim${E} is clipboard compatible."
    else
        exec_anim "install_cmd vim-gtk3"
    fi
    # Save old dotfiles + create synlinks to ~/.vim/ and ~/.vimrc then install vim plugin
    save_folder "${HOME}/.vim" "vim_from_home"
    save_file "${HOME}/.vimrc" "vimrc_from_home"
    save_folder "${HOME}/.config/vim" "vim_from_config"
    create_symlink ${DOTPATH}/vim ${HOME}/.vim
    create_symlink ${DOTPATH}/vim/vimrc ${HOME}/.vimrc
    exec_anim "vim -es -c 'PlugInstall' -c 'PlugUpdate' -c 'qa'" &&  echol "Vim plugins installed."
    print_last
}
# -[ CONFIG_TASK ]--------------------------------------------------------------------------------------------
config_taskw()
{
    print_title "${B}TASKWARRIOR config.${E}"
    # Check if task and time warrior are installed, else install them
    exec_anim "install_cmd task taskwarrior"
    exec_anim "install_cmd timew timewarrior"
    # TODO add taskserveur (client & serveur)
    # Save old dotfile and create link
    save_folder "${HOME}/.task/hook" "taskhook_from_home"
    save_file "${HOME}/.taskrc" "taskrc_from_home"
    save_folder "${HOME}/.config/task" "task_from_config"
    create_symlink ${DOTPATH}/task ${HOME}/.config/task
    create_symlink ${DOTPATH}/task/taskrc ${HOME}/.taskrc
    # Install custom command
    add_custom_cmd "${DOTPATH}/cmds/taskw/get_task_done_by_date.sh" "get_task_done_by_date"
    print_last
}
# -[ INSTALL_CUSTOM_CMD_WLC ]---------------------------------------------------------------------------------
install_other_custom_cmd()
{
    print_title "${B}Other Custom Commands:${E}"
    add_custom_cmd "${DOTPATH}/cmds/WLC/wlc.sh" "wlc"
    print_last
}
# ============================================================================================================
# MAIN
# ============================================================================================================
if command_exists "dpkg";then
    install_pre_requis_cmds
    config_zsh
    config_git
    config_vim
    config_taskw
    install_other_custom_cmd
else
    echo "${R}This installation script works only on debian or Debian-based systems for now!${E}"
fi
