-- ==================================================
-- Basic Settings
-- ==================================================
local set = vim.opt
set.lazyredraw = true
set.splitright = true
set.splitbelow = true
set.expandtab = true
set.tabstop = 2
set.shiftwidth = 2
set.ignorecase = true
set.smartcase = true
set.number = true
set.clipboard = "unnamedplus"
set.termguicolors = true
set.signcolumn = "yes"
set.updatetime = 250
vim.g.mapleader = " "

-- ==================================================
-- Bootstrap lazy.nvim
-- ==================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({"git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath})
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo(
            {
                {"Failed to clone lazy.nvim:\n", "ErrorMsg"},
                {out, "WarningMsg"},
                {"\nPress any key to exit..."}
            },
            true,
            {}
        )
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- ==================================================
-- Plugin Setup
-- ==================================================
require("lazy").setup(
    {
        -- ==================================================
        -- UI Plugins
        -- ==================================================
        {
            "sainnhe/sonokai",
            enabled = true,
            lazy = false,
            priority = 1000,
            opts = {},
            init = function()
                vim.g.sonokai_style = "andromeda"
                vim.g.sonokai_enable_italic = 1
                vim.g.sonokai_disable_italic_comment = 1
                vim.g.sonokai_transparent_background = 0
                vim.g.sonokai_diagnostic_text_highlight = 1
                vim.g.sonokai_diagnostic_line_highlight = 1
                vim.g.sonokai_diagnostic_virtual_text = "colored"
                vim.g.sonokai_better_performance = 1
                vim.g.sonokai_show_eob = 0
                vim.cmd.colorscheme("sonokai")
            end
        },
        {
            "akinsho/bufferline.nvim",
            version = "*",
            dependencies = {"nvim-tree/nvim-web-devicons"},
            opts = {}
        },
        {
            "nvim-lualine/lualine.nvim",
            dependencies = {"nvim-tree/nvim-web-devicons"},
            opts = {}
        },
        -- ==================================================
        -- File Management
        -- ==================================================
        {
            "nvim-tree/nvim-tree.lua",
            lazy = false,
            dependencies = {
                "nvim-tree/nvim-web-devicons"
            },
            config = function()
                require("nvim-tree").setup({})
            end,
            init = function()
                vim.g.loaded_netrw = 1
                vim.g.loaded_netrwPlugin = 1
            end,
            cmd = "NvimTreeFindFile",
            keys = {
                {"<leader>e", ":NvimTreeFindFile<CR>"}
            }
        },
        {
            "ibhagwan/fzf-lua",
            dependencies = {
                "nvim-tree/nvim-web-devicons",
                "folke/trouble.nvim"
            },
            keys = {
                {"<leader>ff", ":lua require('fzf-lua').files()<CR>"},
                {"<leader>fg", ":lua require('fzf-lua').live_grep()<CR>"}
            },
            config = function()
                local config = require("fzf-lua.config")
                local actions = require("trouble.sources.fzf").actions
                config.defaults.actions.files["ctrl-t"] = actions.open
                config.defaults.actions.files["ctrl-a"] = actions.open_all
            end
        },
        -- ==================================================
        -- LSP & Completion
        -- ==================================================
        {
            "williamboman/mason.nvim",
            lazy = false,
            opts = {}
        },
        {
            "williamboman/mason-lspconfig.nvim",
            lazy = false,
            opts = {}
        },
        {
            "neovim/nvim-lspconfig",
            cmd = {"LspInfo", "LspInstall", "LspStart"},
            event = {"BufReadPre", "BufNewFile"},
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",
                "williamboman/mason-lspconfig.nvim"
            },
            config = function()
                vim.diagnostic.config(
                    {
                        virtual_text = false,
                        signs = true,
                        underline = true,
                        update_in_insert = false,
                        severity_sort = true
                    }
                )

                local signs = {Error = " ", Warn = " ", Hint = " ", Info = " "}
                for type, icon in pairs(signs) do
                    local hl = "DiagnosticSign" .. type
                    vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl})
                end

                local on_attach = function(_, bufnr)
                    local opts = {buffer = bufnr, silent = true}
                    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
                    vim.keymap.set({"n", "v"}, "gf", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "gx", vim.diagnostic.open_float, opts)
                    vim.keymap.set("n", "[e", vim.diagnostic.goto_prev, opts)
                    vim.keymap.set("n", "]e", vim.diagnostic.goto_next, opts)
                    vim.keymap.set("n", "gh", vim.lsp.buf.hover, opts)
                end

                local capabilities = require("cmp_nvim_lsp").default_capabilities()

                require("mason-lspconfig").setup(
                    {
                        ensure_installed = {"lua_ls", "ts_ls"},
                        handlers = {
                            function(server_name)
                                local opts = {
                                    capabilities = capabilities,
                                    on_attach = on_attach
                                }
                                if server_name == "lua_ls" then
                                    opts.settings = {
                                        Lua = {
                                            diagnostics = {
                                                globals = {"vim"}
                                            }
                                        }
                                    }
                                end
                                require("lspconfig")[server_name].setup(opts)
                            end
                        }
                    }
                )
            end
        },
        {
            "hrsh7th/nvim-cmp",
            event = "InsertEnter",
            dependencies = {
                "L3MON4D3/LuaSnip",
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-buffer",
                "saadparwaiz1/cmp_luasnip"
            },
            config = function()
                local cmp = require("cmp")
                local luasnip = require("luasnip")

                cmp.setup(
                    {
                        snippet = {
                            expand = function(args)
                                luasnip.lsp_expand(args.body)
                            end
                        },
                        experimental = {
                            ghost_text = {hl_group = "Comment"}
                        },
                        sources = {
                            {name = "copilot"},
                            {name = "path"},
                            {name = "nvim_lsp"},
                            {name = "luasnip", keyword_length = 2},
                            {name = "buffer", keyword_length = 3}
                        },
                        window = {
                            completion = cmp.config.window.bordered(),
                            documentation = cmp.config.window.bordered()
                        },
                        mapping = {
                            ["<C-Space>"] = cmp.mapping.complete(),
                            ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                            ["<C-d>"] = cmp.mapping.scroll_docs(4),
                            ["<CR>"] = cmp.mapping.confirm({select = true}),
                            ["<Tab>"] = cmp.mapping(
                                function(fallback)
                                    if cmp.visible() then
                                        cmp.select_next_item()
                                    elseif luasnip.expand_or_jumpable() then
                                        luasnip.expand_or_jump()
                                    else
                                        fallback()
                                    end
                                end,
                                {"i", "s"}
                            ),
                            ["<S-Tab>"] = cmp.mapping(
                                function(fallback)
                                    if cmp.visible() then
                                        cmp.select_prev_item()
                                    elseif luasnip.jumpable(-1) then
                                        luasnip.jump(-1)
                                    else
                                        fallback()
                                    end
                                end,
                                {"i", "s"}
                            )
                        }
                    }
                )
            end
        },
        -- ==================================================
        -- Code Tools
        -- ==================================================
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function()
                local configs = require("nvim-treesitter.configs")
                configs.setup(
                    {
                        ensure_installed = {
                            "javascript",
                            "typescript",
                            "tsx",
                            "python",
                            "bash",
                            "html",
                            "json",
                            "lua",
                            "yaml",
                            "markdown",
                            "markdown_inline",
                            "vimdoc",
                            "luadoc",
                            "ruby",
                            "vim"
                        },
                        sync_install = false,
                        highlight = {enable = true},
                        indent = {enable = true}
                    }
                )
            end
        },
        {
            "stevearc/conform.nvim",
            event = {"BufWritePre"},
            cmd = {"ConformInfo"},
            opts = {
                formatters_by_ft = {
                    lua = {"stylua"},
                    javascript = {"eslint_d"},
                    typescript = {"eslint_d"},
                    typescriptreact = {"eslint_d"},
                    javascriptreact = {"eslint_d"}
                },
                format_after_save = {
                    lsp_fallback = true,
                    timeout_ms = 500
                },
                formatters = {
                    eslint_d = {
                        condition = function(ctx)
                            return vim.fs.find({".eslintrc", ".eslintrc.js", ".eslintrc.json"}, {path = ctx.dirname})[1]
                        end,
                        async = true
                    }
                }
            },
            config = function(_, opts)
                require("conform").setup(opts)
            end
        },
        {
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            lazy = false,
            opts = {
                ensure_installed = {
                    "stylua",
                    "eslint_d"
                }
            }
        },
        {
            "mfussenegger/nvim-lint",
            event = {"BufWritePre"},
            config = function()
                require("lint").linters_by_ft = {
                    javascript = {"eslint_d"},
                    typescript = {"eslint_d"},
                    typescriptreact = {"eslint_d"},
                    javascriptreact = {"eslint_d"}
                }
            end,
            init = function()
                vim.api.nvim_create_autocmd(
                    {"BufWritePost"},
                    {
                        callback = function()
                            require("lint").try_lint()
                        end
                    }
                )
            end
        },
        -- ==================================================
        -- Git
        -- ==================================================
        {
            "tpope/vim-fugitive",
            cmd = {
                "Git",
                "G",
                "Gdiffsplit",
                "Gread",
                "Gwrite",
                "Ggrep",
                "GMove",
                "GDelete",
                "GBrowse",
                "Git add",
                "Git commit",
                "Git push"
            }
        },
        {
            "lewis6991/gitsigns.nvim",
            event = {"BufRead", "BufNewFile"},
            opts = {
                current_line_blame = false,
                current_line_blame_opts = {
                    delay = 250
                }
            }
        },
        {
            "sindrets/diffview.nvim",
            opts = {},
            keys = {
                {"<leader>dd", ":DiffviewFileHistory %<CR>"},
                {"<leader>dc", ":DiffviewClose<CR>"},
                {"<leader>ds", ":DiffviewOpen<CR>"}
            }
        },
        -- ==================================================
        -- Diagnostics
        -- ==================================================
        {
            "folke/trouble.nvim",
            opts = {},
            cmd = "Trouble",
            keys = {
                {"<leader>xx", "<cmd>Trouble diagnostics toggle<cr>"},
                {"<leader>cs", "<cmd>Trouble symbols toggle<cr>"},
                {"<leader>cl", "<cmd>Trouble lsp toggle<cr>"}
            }
        },
        -- ==================================================
        -- AI
        -- ==================================================
        {
            "zbirenbaum/copilot.lua",
            event = {"InsertEnter"},
            opts = {
                suggestion = {enabled = false},
                panel = {enabled = false}
            }
        },
        {
            "zbirenbaum/copilot-cmp",
            config = function()
                require("copilot_cmp").setup()
            end
        },
        -- ==================================================
        -- Search
        -- ==================================================
        {
            "nvim-pack/nvim-spectre",
            opts = {
                use_trouble_qf = true
            },
            dependencies = {
                "nvim-lua/plenary.nvim"
            },
            keys = {
                {"<leader>sr", ":lua require('spectre').open()<CR>"}
            }
        },
        -- ==================================================
        -- Misc
        -- ==================================================
        {
            "folke/ts-comments.nvim",
            opts = {},
            enabled = vim.fn.has("nvim-0.10.0") == 1
        },
        {
            "windwp/nvim-autopairs",
            event = "InsertEnter",
            opts = {}
        }
    }
)
