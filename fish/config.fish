set -g fish_greeting ""

# Helper to grab git branch and dirty status quickly
function _get_git_info
    if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set -l branch (command git branch --show-current 2>/dev/null)
        if test -z "$branch"
            set branch (command git rev-parse --short HEAD 2>/dev/null)
        end

        if not command git diff --quiet --ignore-submodules HEAD 2>/dev/null
            set_color B3653C # Verdigris Copper
            echo -n " ──  $branch ✗"
        else
            set_color 43B3AE # Verdigris Teal
            echo -n " ──  $branch"
        end
    end
end

function fish_prompt
    set -l last_status $status
    
    # This manually replaces the /home/yusuf path with ~ but keeps everything else full-length
    set -l cwd (string replace -r "^$HOME" "~" $PWD)

    # --- TOP LINE ---
    set_color 43B3AE # Verdigris Teal
    echo -n "╭─  $cwd"
    
    _get_git_info
    echo ""

    # --- BOTTOM LINE ---
    set_color 43B3AE
    echo -n "╰─"

    if test $last_status -ne 0
        set_color B3653C # Verdigris Copper
        echo -n " ✕_ "
    else
        set_color 49B777 
        echo -n " >_ "
    end

    set_color normal
end
