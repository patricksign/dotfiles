local remap = require("me.util").remap
local bufopts = { silent = true, noremap = true }

remap("n", "<C-s>", "<cmd>:w!<cr>", bufopts, "Save File")
remap("n", "<C-q>", "<cmd>:q!<cr>", bufopts, "Quit File")
remap("n", "<leader><leader>", "<cmd>:noh<cr>", bufopts, "No highlight")
remap("n", "<leader>tg", "<cmd>:TigBlame<cr>", bufopts, "Git blame")
remap("n", "<C-f>", "<cmd>:NERDTreeFind<cr>", bufopts, "Current file location")
remap("n", "<C-n>", "<cmd>:NERDTreeToggle<cr>", bufopts, "Open left pannel")
remap("n", "<leader>m", "<cmd>:History<cr>", bufopts, "History open recent files")
remap("n", "<C-h>", "<C-w>h", bufopts, "Jump to left")
remap("n", "<C-j>", "<C-w>j", bufopts, "Jump to bottom")
remap("n", "<C-k>", "<C-w>k", bufopts, "Jump to top")
remap("n", "<C-l>", "<C-w>l", bufopts, "Jump to right")
remap("n", "<C-g>", "<cmd>:vsplit<cr>", bufopts, "vertical split")

