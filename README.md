# Dotfiles
All my configuration files, to install:
`git clone --recurse-submodules -j8 git@github.com:alterGNU/Dotfiles.git ~/.dotfiles && ./.dotfiles/install.sh`

## ZSH : `~/.zshrc`
- Variables:
    - ${CLE}            : path to my usb key
    - ${VIMRC}          : path to my vim dotfile
- Aliases:
    - francinette       : An easy to use testing framework for the 42 projects create by @xicodomingues
    - paco              : shorter version of francinette
    - ccw               : Compilation with Clang cmd and Errors Flags and BSD sys. compatible (strlcpy(),...)
    - gud               : Git Add All then git commit with "UPDATE" as git commit name, then push
- Functions:
    - gad arg1 <arg2>   : Git Add All, then commit with arg1 as commit name, and Git Push to arg2 (keep empty if only one distant repos)
    - gdtt <args>       : Git DiffTool whitout args (i use vimdiff cf .gitconfig), if args are files, will open git
      difftool without asking user if he's sure...

## GIT : `~/.gitconfig`
I use vimdiff as git difftool and have dt as difftool alias.

## VIM : `~/.vim`
### Plugins
- **alexandregv/norminette-vim**    : norminette checking plugin 
- **itchyny/calendar.vim**          : Calendar Sync with google calendar and Tasks
- **morhetz/gruvbox**               : Theme & coloration retro groove
- **mzlogin/vim-markdown-toc**      : TOC for Markdown
- **scrooloose/nerdtree**           : File system explorer
- **scrooloose/syntastic**          : Syntax checking plugin
- **vim-utils/vim-man**             : View man pages in vim
- **vimwiki/vimwiki**               : Personal Wiki for Vim
