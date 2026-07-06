fish_add_path ~/.local/bin

function fish_greeting
    ufetch
end

starship init fish | source
