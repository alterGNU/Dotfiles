# Dotfiles

## Files and Folders
```bash
Dotfiles/
   ├── cmds/                            # Custom command ...
   │   ├── git/                         # ... related to git.
   │   ├── taskw/                       # ... related to task and time warrior.
   │   └── WLC/                         # ... Wiki Link Convertor.
   ├── gitconfig                        # git dotfile (sym-link ~/.gitconfig)
   ├── install.sh                       # install script
   ├── task/                            # Taskwarrior dotfiles folder
   │   ├── gruvbox.theme                # My Color theme
   │   ├── hooks                        # My Hooks (sym-link to ~/.config/task/hooks)
   │   │   ├── on-modify.timetracking   # Track time by adding an UDA duree
   │   │   └── on-modify.timewarrior    # Sync time and task warrior
   │   └── taskrc                       # taskwarrior dotfile (sym-link to ~/.taskrc)
   ├── vim/                             # Vim dotfiles folder (sym-link ~/.vim/)
   │   └── vimrc                        # Vim dotfile (sym-link ~/.vimrc)
   └── zshrc                            # Zsh dotfile (sym-link ~/.zshrc)
```

## Installation
### install.sh script:
They're two cases:
- Use `install.sh` script **AFTER GIT CLONE**:
    - The entire project has been cloned and the install.sh script is located in the folder:
    ```bash
    LOCDOT=<path_to_where_to_clone/the_folder_name> && \
    git clone --recurse-submodules -j8 https://github.com/alterGNU/Dotfiles.git ${LOCDOT} && \
    ${LOCDOT}/install.sh
    ```
- Use `install.sh` script **BEFORE GIT CLONE**:
    - Only the script is download and it will git clone Dotfiles project at ${HOME}/.dotfiles
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

### Details
During the installation process, the install.sh will:
- **create a backup folder** : 
    - for any of my dotfiles, if a version of them already exist in the system, the installation script will 
    create a backup folder to store them : `~/${HOME}/backups/<yyy_mm_dd.hhmmss>/*`
- **config. zsh** : 
    - since my dotfiles project can be cloned anywhere, this script will update in my zshrc file the
      **DOTPATH** variable, it's value will be set to the path where this repo. was cloned.
    ➣ create sym-link from ${DOTPATH}/zshrc to ${HOME}/.zshrc
- **config. git** : 
    ➣ create sym-link from ${DOTPATH}/gitconfig ${HOME}/.gitconfig
- **config. vim** : 
    ➣ create sym-link from ${DOTPATH}/vim ${HOME}/.vim
    ➣ create sym-link from ${DOTPATH}/vim/vimrc ${HOME}/.vimrc
    - Install plugin using vim-cmd `:PlugInstall` && `:PlugUpdate`
- **config. taskwarrior** : 
    ➣ create sym-link from ${DOTPATH}/task ${HOME}/.config/taskvim
    ➣ create sym-link from ${DOTPATH}/task/taskrc ${HOME}/.taskrc
- **Install custom-cmd: `wlc`** : 
    ➣ create sym-link from ${DOTPATH}/cmds/WLC/wlc.sh ${HOME}/.local/bin/wlc
