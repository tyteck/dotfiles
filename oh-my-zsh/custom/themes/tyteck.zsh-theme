function coloredHost() {
    host=$(uname -n)
    case $host in
    "MSI-Laptop")
        echo %{$fg[green]%}Local%{$reset_color%}:
        ;;
    *)
        echo %{$fg[red]%}$host%{$reset_color%}:
        ;;
    esac
    
}
PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT+=' %{$reset_color%}$(coloredHost)%{$fg_bold[cyan]%}%c%{$reset_color%}$(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
# add a yellow x if there is one change (at least) in current repo
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
# nothing has changed
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
