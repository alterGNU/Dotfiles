check_git_status() {
    # Vérifier si on est dans un repo Git
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Not inside a Git repository."
        return 1
    fi

    # Vérifier les modifications non indexées
    if ! git diff --exit-code > /dev/null; then
        echo "Unstaged changes detected."
    fi

    # Vérifier les modifications indexées mais non commités
    if ! git diff --cached --exit-code > /dev/null; then
        echo "Staged changes detected."
    fi

    # Vérifier les sous-modules
    if [[ -n $(git submodule summary) ]]; then
        echo "Submodule changes detected."
    fi

    # Vérifier si le repo est "propre"
    if [[ -z $(git status --porcelain) ]]; then
        echo "Repository is clean."
    fi
}
