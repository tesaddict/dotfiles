-- SET SECTION --
vim.opt.signcolumn = 'yes'
vim.g.mapleader = " "
vim.opt.tabstop = 2
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.colorcolumn = "120"

-- LAZY SECTION --
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
-- Auto-install lazy.nvim if not present
if not vim.uv.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
  print('Done.')
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup({
  {'ellisonleao/gruvbox.nvim'},
  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  {'neovim/nvim-lspconfig'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/nvim-cmp'},
  {'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' }},
  {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
  {'nvim-telescope/telescope-live-grep-args.nvim'},
  {'nvim-telescope/telescope-file-browser.nvim'},
  {'tpope/vim-fugitive'},
  {'nvim-treesitter/nvim-treesitter'},
  {'zbirenbaum/copilot.lua'},
  {'akinsho/toggleterm.nvim', version = "*", config = true},
  {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim", -- Make Markdown buffers look beautiful
    ft = { "markdown", "codecompanion" },
    opts = {
      render_modes = true,
      sign = {
        enabled = false, -- Turn off in the status column
      },
    },
  },
})

-- LSP Section --
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)
-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  end,
})
require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  },
})
local cmp = require('cmp')
cmp.setup({
  sources = {
    {name = 'codecompanion'},
    {name = 'nvim_lsp'},
  },
  mapping = cmp.mapping.preset.insert({
    -- Navigate between completion items
    ['<C-p>'] = cmp.mapping.select_prev_item({behavior = 'select'}),
    ['<C-n>'] = cmp.mapping.select_next_item({behavior = 'select'}),
    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({select = false}),
    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),
    -- Scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  }),
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
})

 -- TELESCOPE SECTION -- 
local builtin = require('telescope.builtin')
require('telescope').setup({
  defaults = {
    cache_picker = {
      num_pickers = 10,
      ignore_empty_prompt = 'true'
    }
  }
})
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set("n", "<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set("n", "<leader>fc", require("telescope-live-grep-args.shortcuts").grep_word_under_cursor)
vim.keymap.set("n", "<leader>fd", ":Telescope file_browser<CR>")
vim.keymap.set("n", "<leader>fs", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")
vim.keymap.set('n', '<leader>fp', builtin.pickers, { desc = 'Telesope display all used pickers' })
vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = 'Telesope display search history' })
require('telescope').load_extension('fzf')
require('telescope').load_extension('live_grep_args')
require("telescope").load_extension('file_browser')

-- COPILOT SECTION --
require('copilot').setup({
  suggestion = { enabled = false },
  panel = { enabled = false },
})

require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = "copilot",
    },
    inline = {
      adapter = "copilot",
    },
  },
})

require('render-markdown').setup()

vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader>fa", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

vim.api.nvim_set_keymap('x', 'y', '"+y', { noremap = true, silent = true } )

-- TERMINAL SECTION --
require("toggleterm").setup({
  start_in_insert = true,       -- Automatically enter terminal mode
  persist_mode = false          -- Don't remember last mode (forces insert)
})
vim.keymap.set('t', '<esc>', '<C-\\><C-N>', t_opts)
vim.keymap.set({ "n", "v", "t" }, "<C-t>", "<cmd>ToggleTerm direction=float<CR>")

vim.keymap.set({ "n", "v" }, "<C-h>", "<C-w>h")
vim.keymap.set({ "n", "v" }, "<C-j>", "<C-w>j")
vim.keymap.set({ "n", "v" }, "<C-k>", "<C-w>k")
vim.keymap.set({ "n", "v" }, "<C-l>", "<C-w>l")

vim.g.clipboard = 'osc52'

vim.o.termguicolors = true
vim.cmd.colorscheme('gruvbox')
vim.o.background = "dark"


-- QUICKFIX SECTION --
vim.api.nvim_create_user_command("BuildQuickfix", function()
  local log_path = vim.fn.expand("~/source/build_logs/build.log")
  if vim.fn.filereadable(log_path) == 0 then
    vim.notify("No build.log found at " .. log_path, vim.log.levels.WARN)
    return
  end

  vim.cmd("cgetfile " .. log_path)
  vim.cmd("copen")
end, {})
vim.opt.errorformat = "%f:%l:%c: error: %m"

-- Quickfix navigation with custom leader keys
vim.keymap.set("n", "<leader>ch", ":cnext<CR>", { desc = "Next quickfix item" })
vim.keymap.set("n", "<leader>cl", ":cprev<CR>", { desc = "Previous quickfix item" })
vim.keymap.set("n", "<leader>co", ":copen<CR>", { desc = "Open quickfix list" })
vim.keymap.set("n", "<leader>cc", ":cclose<CR>", { desc = "Close quickfix list" })
vim.keymap.set("n", "<leader>cl", ":clist<CR>", { desc = "List quickfix items" })
vim.keymap.set("n", "<leader>cb", ":BuildQuickfix<CR>", { desc = "Load build errors from log" })
