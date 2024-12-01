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
# - [ ] Usemode with git-clone
# - [ ] Usemode with curl or wget
# - [ ] Add ASCI art function (start install, then chapter:zshrc install, vim, git )
# ============================================================================================================
 
# ============================================================================================================
# VAR
# ============================================================================================================
# =[ COLORS ]=================================================================================================
R="\033[0;31m"                                   # START RED
V="\033[0;32m"                                   # START GREEN
M="\033[0;33m"                                   # START BROWN
Y="\033[0;93m"                                   # START YELLOW
B="\033[0;36m"                                   # START BLUE
E="\033[0m"                                      # END color balise
 
# =[ PATH ]===================================================================================================
BCK="${HOME}/backups"                            # Path of the backup folder
FLD="${BCK}/$(date +%Y_%m_%d.%Hh%Mm%Ss)"         # Name of the backup folder
DOTPATH=$(dirname $(realpath ${0}))              # Path of the Dotfile folder

# ============================================================================================================
# FUNCTIONS
# ============================================================================================================
 
# -[ CREATE_BCKUP_FOLDER() ]----------------------------------------------------------------------------------
# create a backup folder if not already created
create_bckup_folder() { [[ ! -d ${FLD}/${1} ]] && mkdir -p ${FLD}/${1} ; }
# -[ EXEC_ANIM() ]--------------------------------------------------------------------------------------------
# print animation in frontground while cmd exec in background the print returns.
exec_anim()
{
    local frames=( ▹▹▹▹▹ ▸▹▹▹▹ ▹▸▹▹▹ ▹▹▸▹▹ ▹▹▹▸▹ ▹▹▹▹▸ ▹▹▹▹▹ ▹▹▹▹▹ ▹▹▹▹▹ ▹▹▹▹▹ ▹▹▹▹▹ ▹▹▹▹▹ ▹▹▹▹▹ )
    local delay=0.15
    local cmd="${@}"
    local tmpfile=$(mktemp "${TMPDIR:-/tmp}/exec_anim_${cmd%% *}_XXXXXX")
    trap '[[ -f "${tmpfile}" ]] && rm -f "${tmpfile}"' EXIT RETURN
    ${cmd} > "${tmpfile}" 2>&1 &
    local pid=${!}
    while kill -0 ${pid} 2>/dev/null; do
        for frame in "${frames[@]}"; do printf "\r${frame}" && sleep ${delay} ; done
    done
    printf "\r" && wait ${pid}
    local exit_code=${?}
    printf "\r" && cat "${tmpfile}"
    return ${exit_code}
}

# ============================================================================================================
# MAIN
# ============================================================================================================
 
## -[ INSTALL ZSHRC ]------------------------------------------------------------------------------------------
#sed -i "/^export DOTPATH=/c\export DOTPATH=${DOTPATH}" ${DOTPATH}/zshrc
#[[ -h ~/.zshrc ]] && rm ${HOME}/.zshrc
#[[ -f ~/.zshrc ]] && { create_bckup_folder && mv ${HOME}/.zshrc ${FLD}/zshrc ; }
#ln -s ${DOTPATH}/zshrc ${HOME}/.zshrc
#
## -[ INSTALL GITCONFIG ]--------------------------------------------------------------------------------------
#[[ -h ~/.gitconfig ]] && rm ${HOME}/.gitconfig
#[[ -f ~/.gitconfig ]] && { create_bckup_folder && mv ${HOME}/.gitconfig ${FLD}/gitconfig ; }
#ln -s ${DOTPATH}/gitconfig ${HOME}/.gitconfig
#
## -[ INSTALL VIM ]--------------------------------------------------------------------------------------------
#[[ -h ~/.vim ]] && rm ${HOME}/.vim
#[[ -d ~/.vim ]] && { create_bckup_folder && mv ${HOME}/.vim ${FLD}/vim ; }
#ln -s ${DOTPATH}/vim ${HOME}/.vim
#echo -e "\n" | vim -c "PlugInstall" -c "qa" > /dev/null 2>&1
#echo -e "\n" | vim -c "PlugUpdate" -c "qa" > /dev/null 2>&1
