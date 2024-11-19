# ========================================================================================================== #
#                                   ______   _____   _    _   _____     _____                                #
#                                  |___  /  / ____| | |  | | |  __ \   / ____|                               #
#                                     / /  | (___   | |__| | | |__) | | |                                    #
#                                    / /    \___ \  |  __  | |  _  /  | |                                    #
#                                   / /__   ____) | | |  | | | | \ \  | |____                                #
#                                  /_____| |_____/  |_|  |_| |_|  \_\  \_____|                               #
#                                                                                            by alterGNU     #
# ========================================================================================================== #
 
# =[ EXPORTS ]================================================================================================
# ADD funckeck to PATH
export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:${PATH}"
export PATH=/home/altergnu/.local/funcheck/host:$PATH
export CLE=/media/${USERNAME}/Lexar/
export VIMRC=/home/${USERNAME}/.vim/vimrc
export DOTPATH=/home/altergnu/Projects/Dotfiles
[[ -d ${DOTPATH}/fcts ]] && export FPATH=${DOTPATH}/fcts:$FPATH

# =[ ZSH SETTINGS ]===========================================================================================
# Set name of the theme to load --- if set to "random", it will load a random theme each time oh-my-zsh is 
# loaded, in which case, to know which specific one was loaded, run: echo $RANDOM_THEME 
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?  Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

# -[ SOURCE ]-------------------------------------------------------------------------------------------------
source $ZSH/oh-my-zsh.sh

# =[ FUNCTIONS ]==============================================================================================
autoload -Uz hi          # git add commit
autoload -Uz gac         # git add commit
autoload -Uz gdft        # git difftool
autoload -Uz gus         # git update submodule
autoload -Uz guw         # git update wiki
autoload -Uz update_gpw  # update folder Github-Projects-Wikis

# =[ ALIAS ]==================================================================================================
alias francinette=/home/altergnu/francinette/tester.sh
alias paco=/home/altergnu/francinette/tester.sh
alias ccw="cc -Wall -Wextra -Werror -lbsd"
alias wiki='[[ -d ${HOME}/Wiki ]] && vim ~/Wiki/index.md || echo "alias not available here"'
alias notes='[[ -d ${HOME}/Notes ]] && vim ~/Notes/index.md || echo "alias not available here"'
alias diary='[[ -d ${HOME}/Wiki/diary ]] && vim ~/Wiki/diary/diary.md || echo "alias not available here"'
alias todo='[[ -d ${HOME}/Todo ]] && vim ~/Todo/index.md || echo "alias not available here"'
alias gpw='[[ -d ${HOME}/GPW ]] && vim ~/GPW/Home.md || echo "alias not available here"'
alias wikis=gpw
alias gsu=gus
alias gpwu=update_gpw
alias is_a_gitrepo="git rev-parse --is-inside-work-tree &>/dev/null && echo yes || echo no"
alias gitrepo_is_uptodate="git diff-index --quiet HEAD -- 2> /dev/null && echo yes || echo no"

