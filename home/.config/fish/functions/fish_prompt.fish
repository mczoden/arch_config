function fish_prompt --description "Write out the prompt"
    set --local prefix ""
    set --local suffix ""
    set --local realhome ~

    if set -q DISPLAY
        set prefix "┌─"
        set suffix "└─╼ "
    else
        set suffix "> "
    end

    if not set -q __fish_prompt_hostname
        set -g __fish_prompt_hostname (hostname | cut -d . -f 1)
    end

    if not set -q __git_cb
        set __branch (git branch ^/dev/null | grep \* | sed 's/* //')
        if not test -z $__branch
            if test $__branch = "master"
                set __git_cb "["(set_color green)$__branch(set_color normal)"]"
            else
                set __git_cb "["(set_color brown)$__branch(set_color normal)"]"
            end
        end
    end

    echo -s "$prefix" [ (set_color $fish_color_cwd) "$USER" @ "$__fish_prompt_hostname" (set_color normal) ] \
        [ (set_color blue --bold) (echo $PWD | sed -e "s|$realhome|~|") (set_color normal) ] $__git_cb
    echo -n -s "$suffix"
end
