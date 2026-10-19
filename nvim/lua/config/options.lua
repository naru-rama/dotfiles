local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.ruler = true
opt.showcmd = true
opt.cursorline = true
opt.laststatus = 3
opt.showmode = false          -- lualine shows the mode
opt.cmdheight = 0             -- tiny-cmdline shows the command line in a floating window
opt.title = true
opt.wildmenu = true
opt.pumheight = 10
opt.pumblend = 10
opt.winborder = "rounded"
opt.wrap = false
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.splitbelow = true
opt.splitright = true
opt.mouse = ""

opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.autoindent = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.iskeyword:append("-")

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99

opt.backup = false
opt.swapfile = false
opt.undofile = true
opt.autoread = true
opt.clipboard = "unnamedplus"

opt.timeoutlen = 400          -- show the which-key popup sooner after a prefix

-- shows messages in floating windows; needed by cmdheight = 0 and tiny-cmdline
require("vim._core.ui2").enable({})
