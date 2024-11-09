#!/usr/bin/env bash

# ==================================================================================================
# INSTALL
# install my configuration, making backup folder with old dotfiles before replacing them by links
# ==================================================================================================
 
# =[ VAR ]==========================================================================================
BCK="${HOME}/backups"
FLD="${BCK}/$(date +%Y_%m_%d.%Hh%Mm%Ss)"
DOTPATH=$(dirname $(realpath ${0}))
ACTPWD=${pwd}

# =[ FUNCTION ]=====================================================================================
create_folder() { [[ ! -d ${FLD}/${1} ]] && mkdir -p ${FLD}/${1} ; }

# ==================================================================================================
# MAIN
# ==================================================================================================
# -[ INSTALL ZSHRC ]--------------------------------------------------------------------------------
[[ -h ~/.zshrc ]] && rm ${HOME}/.zshrc
[[ -f ~/.zshrc ]] && { create_folder && mv ${HOME}/.zshrc ${FLD}/zshrc ; }
ln -s ${DOTPATH}/zshrc ${HOME}/.zshrc

# -[ INSTALL GITCONFIG ]----------------------------------------------------------------------------
[[ -h ~/.gitconfig ]] && rm ${HOME}/.gitconfig
[[ -f ~/.gitconfig ]] && { create_folder && mv ${HOME}/.gitconfig ${FLD}/gitconfig ; }
ln -s ${DOTPATH}/gitconfig ${HOME}/.gitconfig

# -[ INSTALL VIM ]----------------------------------------------------------------------------------
[[ -h ~/.vim ]] && rm ${HOME}/.vim
[[ -d ~/.vim ]] && { create_folder && mv ${HOME}/.vim ${FLD}/vim ; }
ln -s ${DOTPATH}/vim ${HOME}/.vim
echo -e "\n" | vim -c "PlugInstall" -c "qa" > /dev/null 2>&1
echo -e "\n" | vim -c "PlugUpdate" -c "qa" > /dev/null 2>&1
