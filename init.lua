-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  { "mattn/emmet-vim" },                    -- Emmet for HTML and CSS expansion
  { "cohama/lexima.vim" },                  -- Auto-close parentheses, quotes, etc.
  { "tpope/vim-surround" },                 -- Easily delete, change and add surroundings in pairs
  { "scrooloose/nerdcommenter" },           -- Easy commenting of code for various languages
  { "scrooloose/nerdtree" },                -- File system explorer
  { "ap/vim-css-color" },                   -- Preview colors in source code
  { "tomasr/molokai" },                     -- Molokai color scheme
  { "junegunn/fzf" },                       -- Fuzzy finder
  { "junegunn/fzf.vim" },                   -- Fuzzy finder Vim integration
  { "easymotion/vim-easymotion" },          -- Vim motions on speed
  { "hrsh7th/nvim-cmp" },                   -- Completion plugin
  { "hrsh7th/cmp-nvim-lsp" },               -- LSP source for nvim-cmp
  { "hrsh7th/cmp-buffer" },                 -- Buffer completions
  { "hrsh7th/cmp-path" },                   -- Path completions
  { "neovim/nvim-lspconfig" },              -- Quickstart configs for Nvim LSP
  { "williamboman/mason.nvim" },            -- Portable package manager for Neovim
  { "williamboman/mason-lspconfig.nvim" },  -- Bridge between mason.nvim and lspconfig
  { "jose-elias-alvarez/null-ls.nvim" },    -- Use Neovim as a language server
  { "nvim-lua/plenary.nvim" },              -- Lua functions library
  { "folke/noice.nvim" },                   -- Highly experimental plugin that replaces the UI for messages, cmdline and the popupmenu
  { "MunifTanjim/nui.nvim" },               -- UI Component Library for Neovim
  { "github/copilot.vim" },                 -- GitHub Copilot for Vim
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup({
        adapters = {
          openai = function()
            return require("codecompanion.adapters").extend("openai", {
              env = {
                api_key = "OPENAI_API_KEY",
              },
            })
          end,
        },
        strategies = {
          chat = {
            adapter = "openai",
          },
          inline = {
            adapter = "openai",
          },
        },
      })
    end,
  },
  {
    "Robitx/gp.nvim",
    config = function()
      require("gp").setup({
        openai_api_key = os.getenv("OPENAI_API_KEY"),
        -- Disable chat features since we're using codecompanion for that
        chat_user_prefix = "💬:",
        chat_assistant_prefix = "🤖:",
        -- Configure Whisper settings
        whisper = {
          enabled = true,
          model = "whisper-1",
        },
      })
    end,
  },
  {
    "epwalsh/obsidian.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  { "rhysd/vim-startuptime" },              -- Measure startup time of Vim
  { "ellisonleao/gruvbox.nvim", priority = 1000 },
  { "ekickx/clipboard-image.nvim" },
  {
    "preservim/vim-markdown",
    dependencies = { "godlygeek/tabular" },
    ft = { "markdown" }
  },

}, {
--  install = { colorscheme = { "gruvbox" } },
  checker = { enabled = true },
})

-- Noice setup
require("noice").setup()

-- Mason and LSP settings
require('mason').setup({
  ui = {
    icons = {
      package_installed = "⭕",
      package_pending = "➡️",
      package_uninstalled = "❌"
    }
  }
})

require('mason-lspconfig').setup()

-- nvim-cmp setup
local cmp = require('cmp')

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  }),
})

-- LSP setup with nvim-cmp capabilities
local nvim_lsp = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")

-- Mason setup (if not already)
require("mason").setup()

mason_lspconfig.setup({
  ensure_installed = { "lua_ls", "ts_ls", "ltex", "pyright" }, -- ← change to your servers
  automatic_enable = false, -- we will configure manually below
})

-- LSP settings for Make "vim" global variable available in Lua files
require('lspconfig').lua_ls.setup({
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
})

-- Autocommand for formatting Python files
vim.cmd [[autocmd BufWritePre *.py lua vim.lsp.buf.format()]]

-- Copilot settings
vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap('i', '<Tab>', 'copilot#Accept("<CR>")', { silent = true, expr = true })

-- codecompanion.nvim key mappings
-- Set your API key as environment variable: export OPENAI_API_KEY="your-key-here"
vim.keymap.set("n", "<leader>gc", "<cmd>CodeCompanionChat Toggle<CR>", { desc = "Toggle AI chat" })
vim.keymap.set("v", "<leader>gc", "<cmd>CodeCompanionChat Toggle<CR>", { desc = "Toggle AI chat with selection" })
vim.keymap.set("v", "<leader>ga", "<cmd>CodeCompanionChat Add<CR>", { desc = "Add selection to chat" })
vim.keymap.set("n", "<leader>ga", "<cmd>CodeCompanionActions<CR>", { desc = "Open AI actions" })
vim.keymap.set("v", "<leader>ga", "<cmd>CodeCompanionActions<CR>", { desc = "Open AI actions for selection" })

-- Inline prompts for quick edits (this is what you want!)
vim.keymap.set("v", "<leader>gr", function()
  -- Save the visual selection marks
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local start_col = vim.fn.col("'<")
  local end_col = vim.fn.col("'>")

  vim.ui.input({ prompt = "Prompt: " }, function(input)
    if input and input ~= "" then
      -- Restore visual selection
      vim.fn.setpos("'<", {0, start_line, start_col, 0})
      vim.fn.setpos("'>", {0, end_line, end_col, 0})
      -- Execute command
      vim.cmd(string.format("'<,'>CodeCompanion %s", input))
    end
  end)
end, { desc = "AI inline prompt on selection" })

-- Whisper voice transcription keybindings
vim.keymap.set({"n", "i"}, "<leader>v", "<cmd>GpWhisper<CR>", { desc = "Whisper voice transcription" })
vim.keymap.set("v", "<leader>v", ":<C-u>'<,'>GpWhisper<CR>", { desc = "Whisper voice transcription (replace selection)" })

-- LSP and diagnostic settings
vim.o.completeopt = "menuone,noselect"
vim.g.lsp_diagnostics_enabled = 1
vim.g.lsp_diagnostics_echo_cursor = 1
vim.g.lsp_text_edit_enabled = 0
vim.g.lsp_diagnostics_virtual_text_enabled = 1
vim.cmd [[highlight link LspErrorHighlight Error]]
vim.cmd [[highlight link LspWarningHighlight Error]]

-- General settings
vim.o.cursorline = true
vim.o.cursorcolumn = true
vim.o.ruler = true
vim.o.history = 1000
vim.o.showcmd = true
vim.o.hlsearch = true
vim.o.scrolloff = 5
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.number = true
vim.o.backup = false
vim.o.swapfile = false
vim.o.linebreak = true
vim.o.expandtab = true
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.g.mapleader = " "

-- Key mappings for general usage
vim.api.nvim_set_keymap('n', '<leader>w', ':w!<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>o', ':Files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>h', ':History<CR>', { noremap = true, silent = true })

-- Key mappings for LSP
vim.keymap.set('n', '<Leader>ld', vim.lsp.buf.definition, { desc = 'LSP go to definition' })
vim.keymap.set('n', '<Leader>bp', '<cmd>bp<CR>', { desc = 'Go to previous buffer' })
vim.keymap.set('n', '<Leader>lh', vim.lsp.buf.hover, { desc = 'LSP hover' })
vim.keymap.set('n', '<Leader>lr', vim.lsp.buf.references, { desc = 'LSP references' })

-- Clipboard key mappings
vim.api.nvim_set_keymap('v', '<Leader>y', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<Leader>d', '"+d', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>p', '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>P', '"+P', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<Leader>p', '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<Leader>P', '"+P', { noremap = true, silent = true })

-- Remap Esc key combinations
vim.api.nvim_set_keymap('i', 'jk', '<Esc>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', 'kj', '<Esc>', { noremap = true, silent = true })

-- Disable search highlight
vim.api.nvim_set_keymap('n', '<Esc><Esc>', ':nohlsearch<CR>', { noremap = true, silent = true })

-- NERDTree mappings
vim.api.nvim_set_keymap('n', '<C-e>', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>nf', ':NERDTreeFind<CR>', { noremap = true, silent = true, desc = "NERDTree find current file" })

-- EasyMotion mappings
vim.api.nvim_set_keymap('n', '<leader>s', '<Plug>(easymotion-bd-f2)', {})
vim.api.nvim_set_keymap('n', '<leader>s', '<Plug>(easymotion-overwin-f2)', {})

-- Matchit plugin. Jump to the matching characters or tags with %
vim.cmd [[runtime macros/matchit.vim]]

-- Colorscheme settings
vim.o.termguicolors = true -- Enable true color support
vim.api.nvim_command('hi Normal guibg=NONE ctermbg=NONE') -- Set the background to be transparent
vim.cmd [[colorscheme gruvbox]] -- If you're using a colorscheme, make sure to set it after these settings

-- Ensure the colorscheme doesn't override the transparent background
vim.api.nvim_command('hi Normal guibg=NONE ctermbg=NONE')
vim.api.nvim_command('hi NonText guibg=NONE ctermbg=NONE')
vim.api.nvim_command('hi LineNr guibg=NONE ctermbg=NONE')
vim.api.nvim_command('hi Folded guibg=NONE ctermbg=NONE')
vim.api.nvim_command('hi EndOfBuffer guibg=NONE ctermbg=NONE')
vim.o.termguicolors = true
vim.cmd [[syntax on]]
vim.o.backspace = "indent,eol,start" -- Make backspace behave more intuitively in insert mode

-- Obsidian.nvim setup
local obsidian_personal_vault = "/Users/wata/Library/Mobile Documents/iCloud~md~obsidian/Documents/personal-wiki"
local obsidian_journal_directory = "/Users/wata/Library/Mobile Documents/iCloud~md~obsidian/Documents/personal-wiki/journal"
local obsidian_work_vault = "/Users/wata/work-wiki"

require("obsidian").setup({
  workspaces = {
    {
      name = "personal",
      path = obsidian_personal_vault,
    },
    {
      name = "work",
      path = obsidian_work_vault,
    },
  },
  templates = {
    folder = "templates",  -- Folder in your vault where templates are stored
    date_format = "%Y-%m-%d",
    time_format = "%H:%M",
  },
  daily_notes = {
    folder = "journal",
    date_format = "%y_%m_%d",
    template = "daily_template.md",  -- Name of the template file in your templates folder
  },
  ui = {
    checkboxes = {
      [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
      ["x"] = { char = "", hl_group = "ObsidianDone" },
    },
  },
  note_id_func = function(title)
    if title and title ~= "" then
      -- Sanitize the title to be a valid filename:
      -- Replace spaces with hyphens, convert to lowercase, and remove invalid characters.
      local sanitized_title = title:gsub(" ", "-"):gsub("[^%w%s%-]", ""):lower()
      return sanitized_title
    else
      -- Fallback if no title is provided (e.g., generate a timestamp-based ID)
      return os.date("note-%Y%m%d-%H%M%S")
    end
  end,

  -- Optional: If you want to ensure the title is also added as an alias in frontmatter
  note_frontmatter_func = function(note)
    if note.title then
      note:add_alias(note.title)
    end
    local out = { id = note.id, aliases = note.aliases, tags = note.tags }
    if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
      for k, v in pairs(note.metadata) do
        out[k] = v
      end
    end
    return out
  end,
})

-- Obsidian key mappings
vim.keymap.set("n", "<leader>wt", "<cmd>ObsidianToday<CR>", { desc = "Open today's daily note" })
vim.keymap.set("n", "<leader>wy", "<cmd>ObsidianYesterday<CR>", { desc = "Open yesterday's daily note" })
vim.keymap.set("n", "<leader>wtm", "<cmd>ObsidianTomorrow<CR>", { desc = "Open tomorrow's daily note" })

-- ltex-ls (LanguageTool) setup for grammar checking
local lspconfig = require('lspconfig')
lspconfig.ltex.setup({
  filetypes = {"markdown", "text", "tex"},
  settings = {
    ltex = {
      language = "en-US",
      -- You can add more languages: ["en-US", "de-DE", "fr", etc.]
      -- language = "auto", -- Auto-detect language
    }
  }
})

-- Open daily note using obsidian.nvim's built-in feature
-- Set this global variable from shell: vim -c "let g:open_journal=1"
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.g.open_journal == 1 then
            vim.defer_fn(function()
                vim.cmd('ObsidianWorkspace personal')
                vim.cmd('cd ' .. obsidian_journal_directory)
                vim.cmd('ObsidianToday')
                vim.cmd('NERDTreeFind')
            end, 300) -- Increased delay slightly for stability
        end
    end,
    once = true
})

-- Define custom highlight for strong text in markdown
-- Highlight between ** and ** | Ignore underscore in words
vim.cmd [[
  augroup MyMarkdownHighlights
    autocmd!
    autocmd FileType markdown syntax match MarkdownStrong /\*\*.\{-}\*\*/
    autocmd FileType iimarkdown highlight MarkdownStrong guifg=#FF0000 ctermfg=red
    autocmd FileType markdown syntax match MarkdownError "\w\@<=\w\@="
  augroup END
]]

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { noremap = true, silent = true })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { noremap = true, silent = true }) -- Move to the previous diagnostic
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { noremap = true, silent = true }) -- Move to the next diagnostic
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { noremap = true, silent = true }) -- Show diagnostics in the location list
-- vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]] -- Show diagnostics automatically in hover window

-- Trigger `checktime` when changing buffers or coming back to vim in terminal.
vim.o.autoread = true
vim.o.updatetime = 250
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    command = "if mode() != 'c' | checktime | endif",
    pattern = { "*" },
})

-- vim-markdown configuration
vim.g.vim_markdown_folding_style_pythonic = 1
vim.g.vim_markdown_folding_level = 6
vim.g.vim_markdown_toc_autofit = 1
vim.g.vim_markdown_fenced_languages = {
  "html", "python", "bash=sh", "lua"
}
vim.g.vim_markdown_frontmatter = 1
vim.g.vim_markdown_new_list_item_indent = 2
