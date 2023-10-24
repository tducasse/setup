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
		"ruby",
		"html",
		"json",
		"lua",
		"yaml",
		"markdown",
		"markdown_inline",
		"go",
	},
})

-- COPILOT
require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
})

-- BUFFERLINE
require("bufferline").setup({
	options = {
		separator_style = "slant",
		offsets = { { filetype = "NvimTree", text = "File Explorer", text_align = "center" } },
	},
})
vim.keymap.set("n", "<leader>b", ":BufferLinePick<CR>")

-- NVIMTREE
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require("nvim-tree").setup({
	git = {
		ignore = false,
	},
})
vim.keymap.set("n", "<leader>e", ":NvimTreeFindFile<CR>")

-- LUALINE
require("lualine").setup()

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

-- LSP
local lsp = require("lsp-zero")
lsp.preset("recommended")
lsp.ensure_installed({
	"lua_ls",
	"tsserver",
	"solargraph",
	"yamlls",
	"jedi_language_server",
	"eslint",
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
		"stylua",
		"eslint_d",
	},
})

-- FORMATTING
require("formatter").setup({
	logging = false,
	filetype = {
		lua = {
			require("formatter.filetypes.lua").stylua,
		},
		javascript = {
			require("formatter.filetypes.javascript").eslint_d,
		},
		javascriptreact = {
			require("formatter.filetypes.javascript").eslint_d,
		},
		typescript = {
			require("formatter.filetypes.javascript").eslint_d,
		},
		typescriptreact = {
			require("formatter.filetypes.javascript").eslint_d,
		},
	},
})
vim.cmd([[
  augroup FormatAutogroup
    autocmd!
    autocmd BufWritePost * FormatWrite
  augroup END
]])
