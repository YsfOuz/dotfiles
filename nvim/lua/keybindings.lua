vim.g.mapleader = " "

local map_multistep = require('mini.keymap').map_multistep
map_multistep("i", "<Tab>", { "pmenu_next" })

vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float)

vim.keymap.set("n", "<leader>e", function() MiniFiles.open() end)
vim.keymap.set("n", "<leader>b", function() MiniPick.builtin.buffers() end)
vim.keymap.set("n", "<leader>g", function() MiniPick.builtin.grep_live() end)
vim.keymap.set("n", "<leader>f", function() MiniPick.builtin.files() end)
