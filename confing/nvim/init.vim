call plug#begin('~/.local/vim/plugged')
    Plug 'crusoexia/vim-monokai'
    Plug 'godlygeek/tabular'
    Plug 'neovim/nvim-lspconfig'
    Plug 'hrsh7th/nvim-compe'
    Plug 'jiangmiao/auto-pairs'
    Plug 'terrortylor/nvim-comment'
    Plug 'mattn/emmet-vim'
    Plug 'alvan/vim-closetag'
    Plug 'sheerun/vim-polyglot'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'p00f/nvim-ts-rainbow'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'lewis6991/gitsigns.nvim'
    Plug 'tpope/vim-fugitive'
    Plug 'junegunn/gv.vim'
    Plug 'mg979/vim-visual-multi', {'branch': 'master'}
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
call plug#end()

colorscheme monokai
" Do not fuck with my tansparent terminal.
"highlight Normal guibg=NONE ctermbg=NONE

let mapleader = ' '

let g:user_emmet_leader_key = '<C-k>'

let g:closetag_filetypes = 'html,xhtml,phtml'
let g:closetag_emptyTags_caseSensitive = 1
let g:closetag_regions = {
    \ 'typescript.tsx': 'jsxRegion,tsxRegion',
    \ 'javascript.jsx': 'jsxRegion',
    \ 'typescriptreact': 'jsxRegion,tsxRegion',
    \ 'javascriptreact': 'jsxRegion',
    \ }
let g:closetag_shortcut = '>'

lua <<EOF
require'nvim_comment'.setup {
    line_mapping     = "<leader>cl",
    operator_mapping = "<leader>c"
}
require'gitsigns'.setup {
    signs = {
        add          = { hl = 'GitSignsAdd',    text = '│', numhl = 'GitSignsAddNr',    linehl = 'GitSignsAddLn'    },
        change       = { hl = 'GitSignsChange', text = '│', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
        delete       = { hl = 'GitSignsDelete', text = '_', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
        topdelete    = { hl = 'GitSignsDelete', text = '‾', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
        changedelete = { hl = 'GitSignsChange', text = '~', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
    },
    numhl = false,
    linehl = false,
    keymaps = {
        noremap = true,
        buffer  = true,
        ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'" },
        ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'" },
        ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
        ['n <leader>hu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
        ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
        ['n <leader>hR'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
        ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
        ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line()<CR>',
        ['o ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>',
        ['x ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>'
  },
  watch_index        = { interval = 1000 },
  current_line_blame = false,
  sign_priority      = 6,
  update_debounce    = 100,
  status_formatter   = nil,  -- Use default
  use_decoration_api = true,
  use_internal_diff  = true, -- If luajit is present
}

local lspconfig = require'lspconfig'
lspconfig.clangd.setup       { on_attach = on_attach }
lspconfig.gopls.setup        { on_attach = on_attach }
lspconfig.rls.setup          { on_attach = on_attach }
lspconfig.hls.setup          { on_attach = on_attach }
lspconfig.zls.setup          { on_attach = on_attach }
lspconfig.pyright.setup      { on_attach = on_attach }
lspconfig.bashls.setup       { on_attach = on_attach }
lspconfig.vimls.setup        { on_attach = on_attach }
lspconfig.tsserver.setup     { on_attach = on_attach }
lspconfig.fortls.setup       { on_attach = on_attach }
lspconfig.purescriptls.setup { on_attach = on_attach }
lspconfig.solargraph.setup   { on_attach = on_attach }
lspconfig.intelephense.setup { on_attach = on_attach }
lspconfig.jsonls.setup       { on_attach = on_attach }
lspconfig.yamlls.setup       { on_attach = on_attach }
--lspconfig.sumneko_lua.setup          { on_attach = on_attach }

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
lspconfig.cssls.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.html.setup  { capabilities = capabilities, on_attach = on_attach }

local sumneko_root_path =
    vim.fn.stdpath('cache')..'/lspconfig/sumneko_lua/lua-language-server'
local sumneko_binary =
    sumneko_root_path.."/bin/Linux/lua-language-server"

lspconfig.sumneko_lua.setup {
    cmd = { sumneko_binary, "-E", sumneko_root_path .. "/main.lua" };
    settings = {
        Lua = {
            runtime     = { version = 'LuaJIT',  path    = vim.split(package.path, ';'), },
            diagnostics = { globals = {'vim'}, },
            workspace   = {
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')]         = true,
                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                },
            },
            telemetry = { enable = false, },
        },
    },
}

vim.o.completeopt = "menuone,noselect"
require'compe'.setup {
    enabled          = true;
    autocomplete     = true;
    debug            = false;
    min_length       = 1;
    preselect        = 'enable';
    throttle_time    = 80;
    source_timeout   = 200;
    incomplete_delay = 400;
    max_abbr_width   = 100;
    max_kind_width   = 100;
    max_menu_width   = 100;
    documentation    = true;
    source = {
        path          = true;
        buffer        = true;
        calc          = true;
        vsnip         = true;
        nvim_lsp      = true;
        nvim_lua      = true;
        spell         = true;
        tags          = true;
        snippets_nvim = true;
--      break haskell
--        treesitter    = true;
    };
}
-- [[
require'nvim-treesitter.configs'.setup {
    ensure_installed = "maintained",
    highlight = { enable = true, },
    incremental_selection = {
        enable  = true,
        keymaps = {
            init_selection    = "gnn",
            node_incremental  = "grn",
            scope_incremental = "grc",
            node_decremental  = "grm",
        },
    },
    rainbow = {
        enable         = true,
        extended_mode  = true,
        max_file_lines = 1000,
    },
    pairs = {
        enable                = true,
        disable               = {},
        highlight_pair_events = {},
        highlight_self        = false,
        goto_right_end        = false,
        fallback_cmd_normal   = "call matchit#Match_wrapper('',1,'n')",
        keymaps               = { goto_partner = "<leader>%" }
    }
}
--]]
EOF

let g:VM_maps = {}
let g:VM_maps["Select Cursor Down"] = 'J'   " start selecting down
let g:VM_maps["Select Cursor Up"]   = 'K'   " start selecting up

match ErrorMsg '\%>80v.\+'
set listchars=eol:¬,tab:>·
"set list
set nowrap
set undofile
set undodir=~/.local/vim/undodir
set tabstop=4
set shiftwidth=4
set expandtab
set ignorecase
set smartcase
set laststatus=0
set fillchars+=vert:│
set autoread

autocmd CursorHold  * checktim
autocmd CursorMoved * checktim
" Good old c.
autocmd BufRead,BufNewFile *.h set filetype=c

inoremap kj <esc>

command W  w
command Wq wq
command Q  q

vnoremap <Tab>   >gv
vnoremap <S-Tab> <gv

nnoremap L  <Cmd>lua vim.lsp.buf.hover()<CR>
nnoremap gD <Cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap gd <Cmd>lua vim.lsp.buf.definition()<CR>
nnoremap gi <cmd>lua vim.lsp.buf.implementation()<CR>

nnoremap <leader>ff <cmd>lua vim.lsp.buf.formatting()<CR>
nnoremap <leader>ca <cmd>lua vim.lsp.buf.code_action()<CR>

nnoremap <C-h> <C-W><C-H>
nnoremap <C-j> <C-W><C-J>
nnoremap <C-k> <C-W><C-K>
nnoremap <C-l> <C-W><C-L>

"nnoremap <S-h> :vertical resize +5<cr>
"nnoremap <S-l> :vertical resize -5<cr>

nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>s :Rg<CR>

"inoremap <expr> <CR>    pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <expr> <C-j>   pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <C-k>   pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <expr> <TAB>   pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

let g:fzf_preview_window = 'right:50%'
let g:fzf_layout         = { 'down': '~40%' }
