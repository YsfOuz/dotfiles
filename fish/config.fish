set -g fish_greeting ""

function fish_prompt
    set -l last_status $status
    set -l cwd (prompt_pwd --full-length-dirs 1)

    set_color 43B3AE
    echo -n $cwd
    set_color normal

    if test $last_status -ne 0
        set_color B3653C
        echo -n " ✕_ "
    else
        set_color 49B777
        echo -n " >_ "
    end

    set_color normal
end

