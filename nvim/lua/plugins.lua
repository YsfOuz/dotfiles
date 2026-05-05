vim.pack.add({
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/mason-org/mason-lspconfig.nvim",
    "https://github.com/nvim-mini/mini.nvim"
})
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls",
        "rust_analyzer",
        "clangd",
        "jdtls",
    },
})

require("mini.starter").setup()
require("mini.basics").setup()
require("mini.misc").setup()
require("mini.extra").setup()
require("mini.git").setup()
require("mini.diff").setup()
require("mini.files").setup()
require("mini.cmdline").setup()
require("mini.pick").setup()

require("mini.pairs").setup()
require("mini.snippets").setup()
require("mini.completion").setup()

require("mini.base16").setup({
    palette = {
        base00 = "#0c2323",
        base01 = "#102c2c",
        base02 = "#143837",
        base03 = "#1a4745",
        base04 = "#f0e3d6",
        base05 = "#c0b5ab",
        base06 = "#999088",
        base07 = "#7a736c",
        base08 = "#b3653c",
        base09 = "#a08e50",
        base0A = "#8da363",
        base0B = "#48b777",
        base0C = "#43b3ae",
        base0D = "#2a91a2",
        base0E = "#3e5586",
        base0F = "#b87333",
    },
  use_cterm = true,
})
require("mini.icons").setup()
require("mini.statusline").setup()
require("mini.tabline").setup()
