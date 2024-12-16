# Wiki Link Convertor

## Problematic
I often use github wiki feature for hosting my project's documentation when I don't want to write Big README files.

I also use vimwiki with mardown syntax to write my own wikis locally.

I therefore decided to use Vimwiki to write local wikis for my various GitHub projects, allowing me to easily display them on the GitHub pages of those projects using this github feature.

The problem is that even though they both use markdown, there are still syntax differences between github wikis and vimwiki wikis:
- Pb1. First Wiki Page:
    - VimWiki   : the first page has to be named **index.md**
    - GitHub    : the first page has to be named **Home.md**
- Pb2. Folders:
    - VimWiki   : feature enable (we can use folders to regroup files)
    - GitHub    : feature desable (we can't use folders)
- Pb3. Links between pages:
    - VimWiki   : `[link to page2](page2.md)`
    - GitHub    : `[link to page2](github.com/<userName>/<ProjectName>/wiki/<page2Name>)`

_(Pb1&2 can be easily solved by the use of symbolic link and by avoiding subfolder creation while editing with vimwiki.)_

This project aims to respond to problem number 3 by allowing all links to be converted to the github format or to the vimwiki format.

## Clone and Add wlc as a command with a sym-link in one of your PATH folder.
_(Don't forget to replace `<your_path/WLC>` by its real value)_
- clone the repo:
    ```
    git clone https://github.com/alterGNU/WikiLinkConvertor.git <your_path/WLC>
    ```
- Makes sure that their is not a command named **wlc**:
    ```
    which wlc
    ```
- Look at your ${PATH} and choose in which folder you want to create your symbolic link to wlc.sh with:
    ```
    echo ${PATH}
    ```
- Create a sym-link _(Here I choose ~/.local/bin)_:
    ```
    ln -s <your_path/WLC>/wlc.sh ~/.local/bin/wlc && source ~/.zshrc
    ```
- Now instead of `your_path/WLC/wlc.sh -v path_to/folder` you can use:
    ```
    wlc -v path_to/folder
    ```

## Convert links from vimwiki to github syntax
```bash
tree ~/path_to/tutu
~/path_to/tutu
  ├── file1.md
  └── file2.md
1 directory, 2 files

wlc -g ~/path_to/tutu
--------------------------
✅ tutu/file1.md, line 3: [link to file2](file2.md) 🔄 [link to file2](https://github.com/alterGNU/tutu/wiki/file2)
✅ tutu/file2.md, line 5: [link to file1](file1.md) 🔄 [link to file1](https://github.com/alterGNU/tutu/wiki/file1)
🟫 tutu/file2.md, line 7: [random weblink](https://www.google.com) 🟤not a file in GITMODE🟤 
🟫 tutu/file2.md, line 8: [link to a nonexisting wiki page](https://github.com/alterGNU/tutu/wiki/not_a_page) 🟤not a file in GITMODE🟤 
🟫 tutu/file2.md, line 9: [link to a nonexisting file](not_a_file) 🟤not a file in GITMODE🟤 
--------------------------

wlc --github ~/path_to/tutu
--------------------------
🟦 tutu/Home.md, line 3: [link to file2](https://github.com/alterGNU/tutu/wiki/file2) 🔵already in GITHUB LINK SYNTAX🔵 
🟦 tutu/prem.md, line 5: [link to file1](https://github.com/alterGNU/tutu/wiki/file1) 🔵already in GITHUB LINK SYNTAX🔵 
🟫 tutu/prem.md, line 7: [random weblink](https://www.google.com) 🟤not a file in GITMODE🟤 
🟫 tutu/prem.md, line 8: [link to a nonexisting wiki page](https://github.com/alterGNU/tutu/wiki/not_a_page) 🟤not a file in GITMODE🟤 
🟫 tutu/prem.md, line 9: [link to a nonexisting file](not_a_file) 🟤not a file in GITMODE🟤 
--------------------------
```

## Convert links from github to vimwiki syntax
```bash
wlc --vimwiki ~/path_to/tutu
--------------------------
✅ tutu/Home.md, line 3: [link to file2](https://github.com/alterGNU/tutu/wiki/file2) 🔄 [link to file2](file2.md)
✅ tutu/prem.md, line 5: [link to file1](https://github.com/alterGNU/tutu/wiki/file1) 🔄 [link to file1](file1.md)
🟫 tutu/prem.md, line 7: [random weblink](https://www.google.com) 🟤not a file in VIMMODE🟤
🟫 tutu/prem.md, line 8: [link to a nonexisting wiki page](https://github.com/alterGNU/tutu/wiki/not_a_page) 🟤not a file in VIMMODE🟤
🟫 tutu/prem.md, line 9: [link to a nonexisting file](not_a_file) 🟤not a file in VIMMODE🟤
--------------------------

wlc -v ~/path_to/tutu
--------------------------
🟦 tutu/Home.md, line 3: [link to file2](file2.md) 🔵already in VIMWIKI LINK SYNTAX🔵 
🟦 tutu/prem.md, line 5: [link to file1](file1.md) 🔵already in VIMWIKI LINK SYNTAX🔵 
🟫 tutu/prem.md, line 7: [random weblink](https://www.google.com) 🟤not a file in VIMMODE🟤
🟫 tutu/prem.md, line 8: [link to a nonexisting wiki page](https://github.com/alterGNU/tutu/wiki/not_a_page) 🟤not a file in VIMMODE🟤
🟫 tutu/prem.md, line 9: [link to a nonexisting file](not_a_file) 🟤not a file in VIMMODE🟤
--------------------------
```

## Notes
- **wlc.sh will not work and will print its usage if:**
    - argC != 2:script need 2arguments argV[0]=**mode**, argV[1]=**path_to/folder**
    - argV[0]:mode   **IS UNKNOWN** _(only: '-v' or '--vimwiki' or '-g' or '--gitub')_
        - '-v' == '--vimwiki'
        - '-g' == '--github'
    - argV[1]:folder **IS NOT A FOLDER**
    - argV[1]:folder **IS NOT** a git repo _(no .git/)_
    - argV[1]:folder **DO NOT HAVE A REMOTE URL** _(no url set)_
    - argV[1]:folder **THE REMOTE URL IS NOT A GITHUB WIKI REPO** _(repo do not end with *.wiki.git)_
