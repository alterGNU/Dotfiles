# Dotfiles
All my configuration files

# ZSH
## Install
If ZSH is install (Oh-My-zsh), cp zshrc to ~/.zshrc
## Personnal config
- Variables:
    - ${CLE}            : path to my usb key
    - ${VIMRC}          : path to my vim dotfile
- Aliases:
    - francinette       : An easy to use testing framework for the 42 projects create by @xicodomingues
    - paco              : shorter version of francinette
    - ccw               : Compilation with Clang cmd and Errors Flags and BSD sys. compatible (strlcpy(),...)
    - gud               : Git Add All then git commit with "UPDATE" as git commit name, then push
    - wiki              : Open vimwiki general index
    - diary             : Open vimwiki diary index
    - todo              : Open vimwiki todo index
- Functions:
    - gad arg1 <arg2>   : Git Add All, then commit with arg1 as commit name, and Git Push to arg2 (keep empty if only one distant repos)
    - gdtt <args>       : Git DiffTool whitout args (i use vimdiff cf .gitconfig), if args are files, will open git
      difftool without asking user if he's sure...
