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

# -[ SOURCE ]-------------------------------------------------------------------------------------------------
source $ZSH/oh-my-zsh.sh

# =[ FUNCTIONS ]==============================================================================================
#autoload -Uz git_add_all_commit_push   # `gaa && gc -m"arg1" ; git push "arg2" "arg3"`
#autoload -Uz git_difftool              # if no arg:`git difftool $PWD`, else `git difftool *argV`
#autoload -Uz git_update_submodule      #
#autoload -Uz git_add_wiki_as_submodule
#autoload -Uz git_update_wiki
#autoload -Uz update_GPW                # update folder Github-Projects-Wikis

# -[ GET_TASK_UUID() ]----------------------------------------------------------------------------------------
# TaskWarrior Get: task _get <ID> <attributs> in clipboard
twg(){ task _get $(echo ${@} | tr ' ' '.') | tee >(xsel -ib) ; }
# TaskWarrior Export: task <ID> export in clipboard
twe(){ task ${1} export | tee >(xsel -ib) ; }

# =[ ALIAS ]==================================================================================================
# -[ VIM ]----------------------------------------------------------------------------------------------------
alias today="vim -c VimwikiMakeDiaryNote"
alias yesterday="vim -c VimwikiMakeYesterdayDiaryNote"
alias wiki='[[ -d ${HOME}/Wiki ]] && vim ~/Wiki/index.md || echo "alias not available here"'
alias diary='[[ -d ${HOME}/Wiki/diary ]] && vim ~/Wiki/diary/diary.md || echo "alias not available here"'
alias todo='[[ -f ${HOME}/Wiki/Todo/index.md ]] && vim ${HOME}/Wiki/Todo/index.md || echo "alias not available here"'
alias idea='[[ -f ${HOME}/Wiki/Todo/Id/index.md ]] && vim ${HOME}/Wiki/Todo/Id/index.md || echo "alias not available here"'
alias question='[[ -f ${HOME}/Wiki/Todo/list_of_Question_tickets.md ]] && vim ${HOME}/Wiki/Todo/list_of_Question_tickets.md || echo "alias not available here"'
alias howto='[[ -f ${HOME}/Wiki/Todo/list_of_How_to_tickets.md ]] && vim ${HOME}/Wiki/Todo/list_of_How_to_tickets.md || echo "alias not available here"'
alias fixit='[[ -f ${HOME}/Wiki/Todo/list_of_Fix_it_tickets.md ]] && vim ${HOME}/Wiki/Todo/list_of_Fix_it_tickets.md || echo "alias not available here"'
alias gpw='[[ -d ${HOME}/GPW ]] && vim ~/GPW/Home.md || echo "alias not available here"'
alias wikis=gpw
# -[ CMDS ]---------------------------------------------------------------------------------------------------
alias ccw="cc -Wall -Wextra -Werror -lbsd"
alias is_a_gitrepo="git rev-parse --is-inside-work-tree &>/dev/null && echo yes || echo no"
alias gitrepo_is_uptodate="git diff-index --quiet HEAD -- 2> /dev/null && echo yes || echo no"
# -[ SCRIPTS ]------------------------------------------------------------------------------------------------
alias francinette=/home/altergnu/francinette/tester.sh
alias paco=/home/altergnu/francinette/tester.sh
# -[ FCTS ]---------------------------------------------------------------------------------------------------
#alias gaacp=git_add_all_commit_push
#alias gdft=git_difftool
#alias gus=git_update_submodule
#alias guw=git_update_wiki
#alias gugpw=git_update_GPW
