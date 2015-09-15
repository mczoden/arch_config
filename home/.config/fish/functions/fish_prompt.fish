function fish_prompt --description "Write out the prompt"
    set --local prefix ""
    set --local suffix ""

    if set -q DISPLAY
        set prefix "┌─"
        set suffix "└─╼ "
    else
        set suffix "> "
    end

    if not set -q __fish_prompt_hostname
        set -g __fish_prompt_hostname (hostname | cut -d . -f 1)
    end

    echo -s "$prefix" [ (set_color $fish_color_cwd) "$USER" @ "$__fish_prompt_hostname" (set_color normal) ] \
        [ (set_color blue --bold) "$PWD" (set_color normal) ]
    echo -n -s "$suffix"
end
