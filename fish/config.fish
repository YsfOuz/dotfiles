# --- GREETING ---
# Replaced empty greeting [cite: 1] with fastfetch
function fish_greeting
        fastfetch -c paleofetch.jsonc
end

# --- PROMPT ---

function fish_prompt
    set -l last_status $status
    
    # IMPROVEMENT: Use prompt_pwd for smart, shortened pathing 
    set -l cwd (prompt_pwd)

    # --- TOP LINE ---
    set_color 43B3AE # Verdigris Teal 
    echo -n "╭─ $cwd"
    
    echo ""

    # --- BOTTOM LINE ---
    set_color 43B3AE # Verdigris Teal 
    echo -n "╰─"

    if test $last_status -ne 0
        set_color B3653C # Verdigris Copper 
        echo -n "{$last_status}──x_ "
    else
        set_color 49B777 # Green 
        echo -n ">_ "
    end

    set_color normal
end
