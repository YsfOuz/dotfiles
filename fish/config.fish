set -px PATH $HOME/.local/bin

function fish_greeting
        fastfetch -c paleofetch.jsonc
end

starship init fish | source

# opencode
fish_add_path /home/yusuf/.opencode/bin
