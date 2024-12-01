# Dotfiles
All my configuration files for:
- Vim : a folder `~/.vim` with vimrc file, all my plugins and other configuration file (add as a submodule)
- Git : my `~/.gitconfig` file
- zsh : my `~/.zshrc` file and a `fcts/` folder with custom command (add to fpath and zshrc)

## installation
They're two possible use cases for the `install.sh` script:
- **AFTER GIT CLONE**:The entire project has been cloned and the install.sh script is located in the folder:
    ```bash
    git clone --recurse-submodules -j8 git@github.com:alterGNU/Dotfiles.git ~/.dotfiles && ./.dotfiles/install.sh
    ```
    _(Note that the location and the folder name '.dotfiles' and it's path '~/' can be change)_
- **BEFORE GIT CLONE**:Only the script is download and it will git clone Dotfiles project at ${HOME}/.dotfiles
    - with curl : 
    ```
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/alterGNU/Dotfiles/refs/heads/main/install.sh)
    ```
    - with wget : 
    ```
    sh -c "$(wget -qO- https://raw.githubusercontent.com/alterGNU/Dotfiles/refs/heads/main/install.sh)
    ```
    - with fetch: 
    ```
    sh -c "$(fetch -o - https://raw.githubusercontent.com/alterGNU/Dotfiles/refs/heads/main/install.sh)
    ```

During the installation process, the install.sh will:
- **create a backup folder** : 
    - for any of my dotfiles, if a version of them already exist in the system, the installation script will 
    create a backup folder to store them : `~/${HOME}/backups/<yyy_mm_dd.hhmmss>/*`
- **config. zsh** : 
    - since my dotfiles project can be cloned anywhere, this script will update in my zshrc file the
      **DOTPATH** variable, it's value will be set to the path where this project was cloned
    - an sym-link from ~/.zshrc to my zshrc file will be created
- **config. git** : 
    - an sym-link from ~/.gitconfig to my gitconfig file will be created
- **config. vim** : 
    - an sym-link from ~/.vim to my vim folder will be created

## ZSH : zshrc file and fcts/ folder

### zshrc file
**zshrc** is a zsh dotfile that :
- contains my zsh settings such as the theme and the plugins that I use
- set ENV-VAR, line that start with `export`, (PATH or FPATH)
- set aliases _(cf aliases)_
- set 'homemade' functions, commands or scripts that I use:
    - can be a function define directly in zshrc file `hi(){ echo hello ; }`
    - can be an alias:
        - using define function : `alias say=$([[ -n ${1} ]] && echo ${1} || echo "nothing to say")`
        - using command + flags : `alias ccw="cc -Wall -Wextra -Werror -lbsd"`
        - using path to scripts : `alias francinette=/home/altergnu/francinette/tester.sh`

For more complex (long) functions, I prefer not to store their definition in my zshrc file.
Writting function in zshrc could be handy will testing/writting them because to see/test changes you'll just have to source the zshrc file).
But when they're done I :
- move them into a folder that I add to the FPATH variable: _(cf fcts/)_ 
- in a file named as the function name.
- and i add the line `autolaod -Uz <function_name>` in my zshrc.

This way we don't overload the zshrc file and we only load functions when they are needed.

- **fcts/** folder: my homemade function


## GIT : gitconfig file
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
