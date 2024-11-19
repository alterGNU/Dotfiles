 
# ============================================================================================================
# Set of personnal git commands
# - gac : git add commit
# - gdft : git difftool
# - gus : git update submodule
# - guw : git update wiki
# - update_gpw : update folder Github-Projects-Wikis
# ============================================================================================================
 
# -[ GAC() ]--------------------------------------------------------------------------------------------------
#GitADd : git add all, commit with arg1 comm then push to arg2 repo's name arg3 branch
gac()
{
    local repo_name=$(basename ${PWD})
    if git rev-parse --is-inside-work-tree &>/dev/null;then
        [[ -n ${1} ]] && local comment="${1}" || local comment="UPDATE"
        [[ -n ${2} ]] && local remote_name="${2}" || local remote_name=$(git remote 2>/dev/null | head -n 1)
        [[ -n ${3} ]] && local actual_branch="${3}" || local actual_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) 
        if ! git diff-index --quiet HEAD -- 2> /dev/null ;then
            git add --all
            git commit -m"${comment}"
        else
            echo "On repo:'${repo_name}', branch '${actual_branch}' is already up_to_date"
        fi
        git push ${remote_name} ${actual_branch}
    else
        echo "${repo_name} is not a git repo"
    fi
}

# -[ GDFT() ]-------------------------------------------------------------------------------------------------
#GitDifFTool: no args=gitdiff all actual rep, args=gitdiff all files in arg1
gdft(){ [[ -n "${1}" ]] && for i in ${@} ; do git difftool -y ${i} ; done || git difftool; }

# -[ GUS() ]--------------------------------------------------------------------------------------------------
# git_update_submodule (update edit submodule branch and GPW) using gac()
gus()
{
    [[ -n ${1} ]] && local comment=${1} || local comment="UPDATE"
    local parent=$(dirname $PWD)
    gac update origin edit
    git -C ${parent} add --all && git -C ${parent} commit -m"${comment}" && git -C ${parent} push
}

# -[ GUW() ]--------------------------------------------------------------------------------------------------
# git_update_wiki (update master submodule branch)
guw()
{
    local repo_name=$(basename ${PWD})
    if git rev-parse --is-inside-work-tree &>/dev/null;then
        local actual_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) 
        [[ ${actual_branch} != "edit" ]] && git checkout edit
        if ! git diff-index --quiet HEAD -- 2> /dev/null ;then 
            gac "UPDATE ${1}" origin edit
            git checkout master
            if [[ $(git rev-parse --abbrev-ref HEAD 2>/dev/null) == "master" ]];then
                git merge -X theirs edit -m"Auto-merge 'edit'->'master'"
                wlc -g .
                gac "UPDATE ${1}" origin master
                git checkout edit
            else
                echo "Something goes wrong while trying to go to the 'master' branch"
            fi
        else
            echo "git wiki :'${repo_name}', branch '${actual_branch}' is already up_to_date"
        fi
    else
        echo "${repo_name} is not a git repo"
    fi
}

# -[ UPDATE_GPW() ]-------------------------------------------------------------------------------------------
# update all GPW submodules using guw()
update_gpw()
{
    local old_pwd="${PWD}"
    local gpw="${HOME}/GPW/"
    if [[ -d ${gpw} ]];then
        cd ${gpw}
        for wiki in $(git submodule status | awk -F ' ' '{print $2}');do
            echo "- git update submodule '${wiki}':"
            cd ${gpw}${wiki}
            guw
            echo "--------------------------------------"
        done 
        cd ${old_pwd}
    else
        echo "No GPW folder at '${gpw}'"
    fi
}
