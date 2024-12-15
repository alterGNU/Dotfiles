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
export ZSH="$HOME/.oh-my-zsh"
export VIMRC=/home/${USERNAME}/.vim/vimrc
export CLE=/media/${USERNAME}/Lexar/
# -[ DOTPATH ]------------------------------------------------------------------------------------------------
export DOTPATH=/home/altergnu/Projects/Dotfiles
[[ -d ${DOTPATH}/fcts ]] && export FPATH=${DOTPATH}/fcts:$FPATH    # ADD $DOTPATH to $FPATH
# -[ PATH ]---------------------------------------------------------------------------------------------------
export PATH="$HOME/.local/bin:${PATH}"                             # ADD ~/.local/bin to $PATH
export PATH=/home/altergnu/.local/funcheck/host:$PATH              # ADD funckeck to $PATH

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

# =[ BINDING KEY ]============================================================================================
bindkey \^U backward-kill-line # Make zsh Ctrl_u behave like bash to delete all before cursor in line

# =[ ALIAS ]==================================================================================================
# -[ CMDS ]---------------------------------------------------------------------------------------------------
alias ccw="cc -Wall -Wextra -Werror -lbsd"
alias is_a_gitrepo="git rev-parse --is-inside-work-tree &>/dev/null && echo yes || echo no"
alias gitrepo_is_uptodate="git diff-index --quiet HEAD -- 2> /dev/null && echo yes || echo no"
# -[ SCRIPTS ]------------------------------------------------------------------------------------------------
alias francinette=/home/altergnu/francinette/tester.sh
alias paco=/home/altergnu/francinette/tester.sh

# =[ SOURCES ]================================================================================================
# -[ OH-MY-ZSH ]----------------------------------------------------------------------------------------------
source $ZSH/oh-my-zsh.sh
# -[ ALIASES ]------------------------------------------------------------------------------------------------
