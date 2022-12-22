function coloredHost() {
    case ${HOST} in
    "mini-forum" | "XPS-13" | "debian" | "tour-fred")
        echo "%{$fg[green]%}${HOST}%{$reset_color%} "
        ;;
    *)
        echo "/!\ ====> %{$fg[red]%}$HOST%{$reset_color%} <==== /!\ "
        ;;
    esac
}

PROMPT="$(coloredHost)%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT+='$(git_prompt_info)%{$reset_color%}%{$fg_bold[cyan]%}%0~%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
# add a yellow x if there is one change (at least) in current repo
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
# nothing has changed
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
