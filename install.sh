#!/usr/bin/env bash

 
# ==================================================================================================
# INSTALL
# Install my configuration wile making backups with old dotfiles.
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
#[[ -h ~/.zshrc ]] && rm ${HOME}/.zshrc
[[ -f ~/.zshrc ]] && { create_folder && mv ${HOME}/.zshrc ${FLD}/zshrc ; }
ln -s ${DOTPATH}/zshrc ${HOME}/.zshrc

# -[ INSTALL VIM ]----------------------------------------------------------------------------------
cd ${DOTPATH} && git submodule update --recursive
cd ${ACTPWD}
#[[ -h ~/.vim ]] && rm ${HOME}/.vim
[[ -d ~/.vim ]] && { create_folder && mv ${HOME}/.vim ${FLD}/vim ; }
ln -s ${DOTPATH}/vim ${HOME}/.vim
echo -e "\n" | vim -c "PlugInstall" -c "qa" > /dev/null 2>&1
echo -e "\n" | vim -c "PlugUpdate" -c "qa" > /dev/null 2>&1
