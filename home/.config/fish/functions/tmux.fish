function tmux 
    set --local tmux_opt ""

    switch $__mc_os
        case Linux
            if test $TERM = "linux"
                command tmux $argv
            else
                command tmux -2 $argv
            end
        case Darwin
            command tmux $argv
        case *
            command tmux $argv
    end
end
