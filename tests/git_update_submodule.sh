#! /bin/zsh

# =[ VAR ]====================================================================================================
LEN=90
git_dir_name="git_parent_repo"                 # git repo. directory name
git_subdir_name="git_sub_repo"                 # git repo. submodule directory name
git_dir="${HOME}/${git_dir_name}"              # git repo. directory abs_path
git_subdir="${git_dir}/${git_subdir_name}"     # git repo. submodule directory abs_path
abs_path=$(realpath ${0})
filename=$(basename ${0})
par_path=${abs_path%\/*}
G="\033[0;32m"                                 # START GREEN
R="\033[0;31m"                                 # START RED
B="\033[0;36m"                                 # START AZURE
M="\033[0;33m"                                 # START BROWN
E="\033[0m"                                    # END color balise
Y="\033[0;93m"                                 # START YELLOW

# =[ FCT ]====================================================================================================
# -[ PNT() ]--------------------------------------------------------------------------------------------------
#print n time function
pnt() { for i in $(seq 0 $((${2})));do echo -en ${1};done;}
# -[ PRINTL ]-------------------------------------------------------------------------------------------------
# print test line
printl() { echo -en ${1} && pnt ${2} $(( LEN - ${#1} )) && echo }
# -[ CLEANUP ]------------------------------------------------------------------------------------------------
# clean up fct
cleanup() { [[ -d "${git_dir}" ]] && rm -rf "${git_dir}" ; }

# ============================================================================================================
# MAIN
# ============================================================================================================
 
# =[ CHECK START ]============================================================================================
[[ -d "${git_dir}" ]] && { echo "a folder ${git_dir} already exist, change git_dir value in ${abs_path}" && exit ; }
[[ -f "${git_dir}" ]] && { echo "a file ${git_dir} already exist, change git_dir value in ${abs_path}" && exit ; }

# =[ CLEANUP AND TRAP ]=======================================================================================
trap cleanup EXIT SIGINT

# =[ SOURCE AND ALIAS ]=======================================================================================
source "${par_path%\/*}/fcts/${filename%\.*}" && echo "source ${par_path%\/*}/fcts/${filename%\.*}"
alias cmd=${filename%\.*}

# =[ TEST1 ]==================================================================================================
printl "\nTest 1: '${git_dir_name}' is not a git repo" "."
echo -e "${B}'${git_dir}' is not a git repo${E}"
cd ${HOME} && mkdir ${git_dir} && cd ${git_dir} && cmd
[[ ${?} -eq 2 ]] && { pnt "." $(( LEN - 6)) && echo -en "${G}PASS\n${E}" ; } || { pnt "." $(( LEN - 6)) && echo -en "${G}FAIL\n${E}" && exit ; }

# =[ TEST2 ]==================================================================================================
printl "\nTest 2: '${git_dir_name}' is a git repo BUT NOT A SUBMODULE YET" "."
echo -e "${Y}'${git_dir_name}' is a git repo but not inside another git repo, it should return:${E}"
echo -e "${B}'${git_dir}' is not a git submodule${E}"
git init > /dev/null 2>&1 && cmd
[[ ${?} -eq 3 ]] && { pnt "." $(( LEN - 6)) && echo -en "${G}PASS\n${E}" ; } || { pnt "." $(( LEN - 6)) && echo -en "${G}FAIL\n${E}" && exit ; }

# =[ TEST3 ]==================================================================================================
printl "\nTest 3: '${git_subdir_name}' is not a git repo (still in ${git_dir})" "."
echo -e "${Y}'${git_subdir_name}' is a git repo inside a git repo but has no commit yet:${E}"
echo -e "${B}'${git_subdir}' is not a git submodule${E}"
mkdir ${git_subdir} && cd ${git_subdir} && git init > /dev/null 2>&1 && cmd
[[ ${?} -eq 3 ]] && { pnt "." $(( LEN - 6)) && echo -en "${G}PASS\n${E}" ; } || { pnt "." $(( LEN - 6)) && echo -en "${G}FAIL\n${E}" && exit ; }

# =[ TEST4 ]==================================================================================================
printl "\nTest 4: '${git_subdir_name})' had is first commit but NOT a ${git_dir_name} SUBMODULE YEY" "."
echo -e "${Y}'${git_subdir_name}' is a git repo inside a git repo with a commit that returns:${M}"
cd ${git_subdir} && touch first_file.md && git add --all && git commit -m"first commit"
echo -e "${Y}but not add as a submodule yet so should return:${E}"
echo -e "${B}'${git_subdir}' is not a git submodule${E}" && cmd
[[ ${?} -eq 3 ]] && { pnt "." $(( LEN - 6)) && echo -en "${G}PASS\n${E}" ; } || { pnt "." $(( LEN - 6)) && echo -en "${G}FAIL\n${E}" && exit ; }

# =[ TEST5 ]==================================================================================================
printl "\nTest 5: '${git_subdir_name}' was ADD as Submodule of ${git_dir}" "."
cd ${git_dir} && git submodule add ${git_subdir} ${git_subdir_name}
echo -e "${Y}'${git_subdir_name}' is NOW a submodule, see the 'cat .gitmodules':${M}"
cat .gitmodules
echo -en "${E}"
echo -e "${Y}git commit returns:${M}"
git commit -m"ADD submodule"
echo -e "${Y}Since nothing was add since add as submodule, the command should return:\n${B}'${git_subdir}' is already up_to_date.${E}"
cd ${git_subdir} && cmd
[[ ${?} -eq 0 ]] && { pnt "." $(( LEN - 6)) && echo -en "${G}PASS\n${E}" ; } || { pnt "." $(( LEN - 6)) && echo -en "${G}FAIL\n${E}" && exit ; }

# =[ TEST6 ]==================================================================================================
printl "\nTest 6: ${git_dir_name}=uptodate ${git_subdir_name}=NOT UP TO DATE" "."
cd ${git_subdir} && touch second_file.txt 
echo -e "${Y}'${git_subdir_name}' have a new file, not add, not commit...gaacp subdir then dir returns:${M}"
cd ${git_subdir} && cmd
res_cmd=${?}
echo -e "${B}The '${git_subdir_name}', submodule of '${git_dir_name}', has been successfully updated!${E}"
[[ ( ${res_cmd} -eq 0 ) && ( -z $(git -C ${git_dir} status --porcelain) ) && (  -z $(git -C ${git_subdir} status --porcelain)  ) ]] && { pnt '.' $(( LEN - 6)) && echo -en "${G}PASS${E}\n" ; } || { pnt '~' $(( LEN - 6)) && echo -en "${R}FAIL${E}\n" && exit ; }

# =[ TEST7 ]==================================================================================================
printl "\nTest 7: ${git_dir_name}=uptodate ${git_subdir_name}=NOT UP TO DATE" "."
cd ${git_subdir} && touch third_not_commit.txt && git add third_not_commit.txt
echo -e "${Y}'${git_subdir_name}' have a new file, ADD but not commit...gaacp subdir then dir returns:${M}"
cd ${git_subdir} && cmd
res_cmd=${?}
echo -e "${B}The '${git_subdir_name}', submodule of '${git_dir_name}', has been successfully updated!${E}"
[[ ( ${res_cmd} -eq 0 ) && ( -z $(git -C ${git_dir} status --porcelain) ) && (  -z $(git -C ${git_subdir} status --porcelain)  ) ]] && { pnt '.' $(( LEN - 6)) && echo -en "${G}PASS${E}\n" ; } || { pnt '~' $(( LEN - 6)) && echo -en "${R}FAIL${E}\n" && exit ; }

# =[ TEST8 ]==================================================================================================
printl "\nTest 8: ${git_dir_name}=uptodate ${git_subdir_name}=NOT UP TO DATE" "."
cd ${git_subdir} && touch this_one_is_committed.txt && git -C ${git_subdir} add this_one_is_committed.txt && git -C ${git_subdir} commit -m"UPDATE" > /dev/null
echo -e "${Y}'${git_subdir_name}' have a new file, ADD & COMMIT...but not add to git_dir:gaacp the '${git_dir_name}' returns:${M}"
cd ${git_subdir} && cmd
res_cmd=${?}
echo -e "${B}'${git_subdir_name}' had commits not followed by ${git_dir_name}, the two repo. are now in sync.${E}"
[[ ( ${res_cmd} -eq 0 ) && ( -z $(git -C ${git_dir} status --porcelain) ) && (  -z $(git -C ${git_subdir} status --porcelain)  ) ]] && { pnt '.' $(( LEN - 6)) && echo -en "${G}PASS${E}\n" ; } || { pnt '~' $(( LEN - 6)) && echo -en "${R}FAIL${E}\n" && exit ; }

# =[ TEST9 ]==================================================================================================
printl "\nTest 9: ${git_dir_name}=NOT UP TO DATE ${git_subdir_name}=update" "."
cd ${git_dir} && touch nope.txt 
echo -e "${Y}'${git_dir_name}' have a new file not add & COMMIT that should stay untrack ('${git_subdir_name}' is uptodate), the command should return:\n${B}'${git_subdir}' is already uptodate${E}"
cd ${git_subdir} && cmd
res_cmd=${?}
[[ ( ${res_cmd} -eq 0 ) && ( -n $(git -C ${git_dir} status --porcelain) ) && (  -z $(git -C ${git_subdir} status --porcelain)  ) ]] && { pnt '.' $(( LEN - 6)) && echo -en "${G}PASS${E}\n" ; } || { pnt '~' $(( LEN - 6)) && echo -en "${R}FAIL${E}\n" && exit ; }

# =[ TEST10 ]==================================================================================================
printl "\nTest 10: ${git_dir_name}=NOT UP TO DATE ${git_subdir_name}=NOT UP TO DATE" "."
echo -e "${Y}'${git_dir_name}' have a new file and '${git_subdir_name}' have a new file, git_dir should stay untrack:${M}"
cd ${git_subdir} && touch tototototototo.txt && cmd
res_cmd=${?}
echo -e "${B}The '${git_subdir_name}' submodule of '${git_dir_name}' has been successfully updated!${E}"
[[ ( ${res_cmd} -eq 0 ) && ( -n $(git -C ${git_dir} status --porcelain) ) && (  -z $(git -C ${git_subdir} status --porcelain)  ) ]] && { pnt '.' $(( LEN - 6)) && echo -en "${G}PASS${E}\n" ; } || { pnt '~' $(( LEN - 6)) && echo -en "${R}FAIL${E}\n" && exit ; }

cleanup

# =[ TEST1 ]==================================================================================================
cd ${HOME} && mkdir ${git_dir} && cmd ${git_dir}
[[ ${?} -eq 2 ]] && { pnt "." $(( LEN - 6)) && echo -en "${G}PASS\n${E}" ; } || { pnt "." $(( LEN - 6)) && echo -en "${G}FAIL\n${E}" && exit ; }

# =[ TEST2 ]==================================================================================================
git -C ${git_dir} init > /dev/null 2>&1 && cmd ${git_dir}
[[ ${?} -eq 3 ]] && { pnt "." $(( LEN - 6)) && echo -en "${G}PASS\n${E}" ; } || { pnt "." $(( LEN - 6)) && echo -en "${G}FAIL\n${E}" && exit ; }

# =[ TEST3 ]==================================================================================================
mkdir ${git_subdir} && git -C ${git_subdir} init > /dev/null 2>&1 && cmd ${git_subdir} 
[[ ${?} -eq 3 ]] && { pnt "." $(( LEN - 6)) && echo -en "${G}PASS\n${E}" ; } || { pnt "." $(( LEN - 6)) && echo -en "${G}FAIL\n${E}" && exit ; }

# =[ TEST4 ]==================================================================================================
touch ${git_subdir}/first_file.md && git -C ${git_subdir} add --all && git -C ${git_subdir} commit -m"first commit" > /dev/null && cmd ${git_subdir}
[[ ${?} -eq 3 ]] && { pnt "." $(( LEN - 6)) && echo -en "${G}PASS${E}\n" ; } || { pnt "." $(( LEN - 6)) && echo -en "${G}FAIL\n${E}" && exit ; }

# =[ TEST5 ]==================================================================================================
git -C ${git_dir} submodule add ${git_subdir} ${git_subdir_name} > /dev/null && git -C ${git_dir} commit -m"ADD submodule" > /dev/null && cmd ${git_subdir}
[[ ${?} -eq 0 ]] && { pnt "." $(( LEN - 6)) && echo -en "${G}PASS\n${E}" ; } || { pnt "." $(( LEN - 6)) && echo -en "${G}FAIL\n${E}" && exit ; }

# =[ TEST6 ]==================================================================================================
touch ${git_subdir}/second_file.txt && cmd ${git_subdir}
[[ ( ${?} -eq 0 ) && ( -z $(git -C ${git_dir} status --porcelain) ) && (  -z $(git -C ${git_subdir} status --porcelain)  ) ]] && { pnt '.' $(( LEN - 6)) && echo -en "${G}PASS${E}\n" ; } || { pnt '~' $(( LEN - 6)) && echo -en "${R}FAIL${E}\n" && exit ; }

# =[ TEST7 ]==================================================================================================
touch ${git_subdir}/third_not_commit.txt && git -C ${git_subdir} add third_not_commit.txt && cmd ${git_subdir}
res_cmd=${?}
[[ ( ${res_cmd} -eq 0 ) && ( -z $(git -C ${git_dir} status --porcelain) ) && (  -z $(git -C ${git_subdir} status --porcelain)  ) ]] && { pnt '.' $(( LEN - 6)) && echo -en "${G}PASS${E}\n" ; } || { pnt '~' $(( LEN - 6)) && echo -en "${R}FAIL${E}\n" && exit ; }

 =[ TEST8 ]==================================================================================================
touch ${git_subdir}/this_one_is_committed.txt && git -C ${git_subdir} add this_one_is_committed.txt && git -C ${git_subdir} commit -m"UPDATE" > /dev/null && cmd ${git_subdir} 
[[ ( ${?} -eq 0 ) && ( -z $(git -C ${git_dir} status --porcelain) ) && (  -z $(git -C ${git_subdir} status --porcelain)  ) ]] && { pnt '.' $(( LEN - 6)) && echo -en "${G}PASS${E}\n" ; } || { pnt '~' $(( LEN - 6)) && echo -en "${R}FAIL${E}\n" && exit ; }

# =[ TEST9 ]==================================================================================================
touch ${git_dir}/nope.txt && cmd ${git_subdir}
[[ ( ${?} -eq 0 ) && ( -n $(git -C ${git_dir} status --porcelain) ) && (  -z $(git -C ${git_subdir} status --porcelain)  ) ]] && { pnt '.' $(( LEN - 6)) && echo -en "${G}PASS${E}\n" ; } || { pnt '~' $(( LEN - 6)) && echo -en "${R}FAIL${E}\n" && exit ; }

# =[ TEST10 ]==================================================================================================
touch ${git_subdir}/tototototototo.txt && cmd ${git_subdir}
[[ ( ${?} -eq 0 ) && ( -n $(git -C ${git_dir} status --porcelain) ) && (  -z $(git -C ${git_subdir} status --porcelain)  ) ]] && { pnt '.' $(( LEN - 6)) && echo -en "${G}PASS${E}\n" ; } || { pnt '~' $(( LEN - 6)) && echo -en "${R}FAIL${E}\n" && exit ; }
