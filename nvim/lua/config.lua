-- THEMES
vim.g.sonokai_style = "andromeda"
vim.g.sonokai_better_performance = 1
vim.cmd("colorscheme sonokai")

-- TELESCOPE
local builtin = require("telescope.builtin")
require("telescope").setup({
	pickers = {
		find_files = {

			hidden = true,
		},
	},
})
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})

-- COPILOT
require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
})

-- TREESITTER
require("nvim-treesitter.configs").setup({
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
	ensure_installed = {
		"javascript",
		"typescript",
		"python",
		"bash",
		"rust",
		"html",
		"json",
		"lua",
		"yaml",
		"markdown",
		"markdown_inline",
	},
})

-- BUFFERLINE
require("bufferline").setup({})

-- NVIMTREE
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require("nvim-tree").setup({
	git = {
		ignore = false,
	},
})
vim.keymap.set("n", "<leader>e", ":NvimTreeFocus<CR>")

-- LUALINE
require("lualine").setup()

-- LSP
local lsp = require("lsp-zero")
lsp.preset("recommended")
lsp.ensure_installed({
	"tsserver",
	"eslint",
	"lua_ls",
	"rust_analyzer",
	"jedi_language_server",
})
lsp.nvim_workspace()
lsp.set_preferences({
	set_lsp_keymaps = false,
})
lsp.setup()
local cmp = require("cmp")
cmp.setup({
	sources = {
		{ name = "copilot" },
		{ name = "path" },
		{ name = "nvim_lsp" },
		{ name = "buffer", keyword_length = 3 },
		{ name = "luasnip", keyword_length = 2 },
	},
	experimental = {
		ghost_text = {
			hl_group = "Comment",
		},
	},
	mapping = {
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	},
})
vim.cmd([[autocmd BufWritePre *.tsx,*.ts,*.jsx,*.js EslintFixAll]])

-- LSP BINDINGS
require("lspsaga").setup({
	code_action_lightbulb = {
		enable = false,
		sign = false,
		virtual_text = false,
	},
})
vim.keymap.set("n", "gr", "<cmd>Lspsaga lsp_finder<CR>", { silent = true })
vim.keymap.set({ "n", "v" }, "gf", "<cmd>Lspsaga code_action<CR>", { silent = true })
vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { silent = true })
vim.keymap.set("n", "gx", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true })
vim.keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true })
vim.keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true })
vim.keymap.set("n", "gh", "<cmd>Lspsaga hover_doc<CR>", { silent = true })

-- MASON TOOLS
require("mason-tool-installer").setup({
	ensure_installed = {
		"black",
		"stylua",
		"flake8",
		"isort",
	},
})

-- NULL-LS
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require("null-ls")
null_ls.setup({
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.black.with({
			extra_args = { "-l", "80" },
		}),
		null_ls.builtins.formatting.isort,
		null_ls.builtins.diagnostics.flake8,
	},
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ bufnr = bufnr })
				end,
			})
		end
	end,
})

-- FUGITIVE
vim.cmd([[
function! DiffNav()

exe 'tabedit %'
exe 'term git log -p %'
exe 'startinsert'
endfunction

nnoremap <silent> <leader>d :call DiffNav()<CR>
]])

-- GITSIGNS
require("gitsigns").setup({
	current_line_blame = true,
	current_line_blame_opts = {
		delay = 250,
	},
})

-- COMMENT
require("Comment").setup()

-- AUTOPAIRS
require("nvim-autopairs").setup()
