#!bash

_crypt() {
    COMPREPLY=()
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword
    case "$prev" in
        crypt)
            COMPREPLY=( $(compgen -W "-h --help init add cat clip ls rm mv exec pwgen edit" -- $cur) )
            ;;
        add|clip|cat|rm|mv|edit)
            local keys=$(crypt ls)
            COMPREPLY=( $(compgen -W "$keys" -- $cur) )
            ;;
        *)
            local keys=$(ls)
            COMPREPLY=( $(compgen -W "$keys" -- $cur) )
            ;;
    esac
}
complete -F _crypt crypt
