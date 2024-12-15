#!/usr/bin/env bash

# ============================================================================================================
# This script display in stdout AND copy to CLIPBOARD the task attribut(task_ID and attribut_name pass as arguments)
#   - ./tw_get_task_attribut.sh <task_ID> <attribut_name>
#
# - Requirements:
#   - taskwarrior package for task command
#   - coreutils package for tee and tr commands
#   - xsel package for xsel command (wl-copy omly work in Wayland, xsel work on X11 and wayland).
# ============================================================================================================
 
# ============================================================================================================
# MAIN
# ============================================================================================================
task _get $(echo ${@} | tr ' ' '.') | tee >(xsel -ib) ;
