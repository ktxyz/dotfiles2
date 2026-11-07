-- ~/.config/nvim/init.lua — kickstart-style single file
-- Neovim >= 0.11 (modern vim.lsp.config API)

-- leaders before plugins ----------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- options -------------------------------------------------------------------
local opt = vim.opt
vim.schedule(function()
	opt.clipboard = "unnamedplus" -- system clipboard
end)
opt.relativenumber = true
opt.number = true
opt.mouse = "a"
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 400
opt.splitright = true
opt.splitbelow = true
opt.inccommand = "split"
opt.cursorline = true
opt.scrolloff = 10
opt.confirm = true

-- basics --------------------------------------------------------------------
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Focus left" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Focus down" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Focus up" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Focus right" })

-- plugin manager --------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv.fs_stat(lazypath)) then
	local out = vim.fn.system({
		"git", "clone", "--filter=blob:none", "--branch=stable",
		"https://github.com/folke/lazy.nvim.git", lazypath,
	})
	if vim.v.shell_error ~= 0 then
		error("Failed to clone lazy.nvim:\n" .. out)
	end
end
opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		-- Colorscheme: Nord to match the terminal rice
		{
			"shaunsingh/nord.nvim",
			priority = 1000,
			init = function() vim.cmd.colorscheme("nord") end,
		},

		-- Treesitter: better highlighting + indentation
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			main = "nvim-treesitter.configs",
			opts = {
				ensure_installed = {
					"bash", "c", "cpp", "go", "lua", "python",
					"rust", "vim", "vimdoc", "zig", "markdown",
				},
				highlight = { enable = true },
			},
		},

		-- Fuzzy finder
		{
			"nvim-telescope/telescope.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			keys = {
				{ "<leader>sf", "<cmd>Telescope find_files<cr>",  desc = "[S]earch [F]iles" },
				{ "<leader>sg", "<cmd>Telescope live_grep<cr>",   desc = "[S]earch by [G]rep" },
				{ "<leader><leader>", "<cmd>Telescope buffers<cr>", desc = "[ ]Find existing buffers" },
				{ "<leader>sh", "<cmd>Telescope help_tags<cr>",   desc = "[S]earch [H]elp" },
			},
			opts = {
				defaults = {
					layout_config = { horizontal = { preview_width = 0.5 } },
				},
			},
		},

		-- LSP: your actual toolchain (clangd, gopls, rust, zig)
		{
			"neovim/nvim-lspconfig",
			config = function()
				local servers = {
					clangd = {},
					gopls = {},
					rust_analyzer = {},
					zls = {},
				}
				for name, cfg in pairs(servers) do
					vim.lsp.config(name, cfg)
					vim.lsp.enable(name)
				end
			end,
		},
	},
	install = { colorscheme = { "nord" } },
	checker = { enabled = false },
	performance = {
		rtp = {
			disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
		},
	},
})
