set shiftwidth=2
set tabstop=2
set expandtab
set hlsearch
set autoindent
set signcolumn=yes
set wildmenu
set wildoptions=pum,fuzzy
set ttimeoutlen=50
set updatetime=50
set number
set wildignore=*.dump,*.o,*.tmp
"set completeopt=menuone,noselect,noinsert
set cursorline
set showmode
set backspace=indent,eol,start
set foldmethod=marker

map <C-l> <Cmd>set nohlsearch<CR>

colorscheme habamax

set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

packadd vim-jetpack
call jetpack#begin()
  Jetpack 'tani/vim-jetpack', {'opt': 1}

  Jetpack 'ryicoh/deepl.vim'

  Jetpack 'haya14busa/vim-edgemotion'
  Jetpack 'justinmk/vim-sneak'

  Jetpack 'prabirshrestha/vim-lsp', {'commit': 'c4bae1f'}
  Jetpack 'mattn/vim-lsp-settings'
  Jetpack 'prabirshrestha/asyncomplete.vim'
  Jetpack 'prabirshrestha/asyncomplete-lsp.vim'

  Jetpack 'hrsh7th/vim-vsnip'
  Jetpack 'hrsh7th/vim-vsnip-integ'
  Jetpack 'rafamadriz/friendly-snippets'

  Jetpack 'tpope/vim-fugitive'
  Jetpack 'tpope/vim-rhubarb'
  Jetpack 'tpope/vim-surround'
  Jetpack 'tpope/vim-commentary'
  Jetpack 'tpope/vim-repeat'

  Jetpack 'ryuichiroh/vim-cspell', {'tag': 'v0.3'}

  Jetpack 'jparise/vim-graphql', { 'for': 'graphql' }
  Jetpack 'leafgarland/typescript-vim', { 'for': ['typescript', 'typescriptreact'] }
  Jetpack 'peitalin/vim-jsx-typescript', { 'for': 'typescriptreact' }

  Jetpack 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Jetpack 'junegunn/fzf.vim'

call jetpack#end()

let g:lsp_signature_help_delay = 50
let g:lsp_diagnostics_echo_cursor = 0
let g:lsp_diagnostics_echo_delay = 50
let g:lsp_diagnostics_float_delay = 100
let g:lsp_diagnostics_float_cursor = 0
let g:lsp_diagnostics_virtual_text_delay = 50
let g:lsp_diagnostics_virtual_text_enabled = 1
let g:lsp_diagnostics_virtual_text_align = 'after'
let g:lsp_diagnostics_virtual_text_padding_left = 2
let g:lsp_diagnostics_virtual_text_wrap = 'truncate'
let g:lsp_diagnostics_highlights_delay = 50
let g:lsp_diagnostics_signs_delay = 50
let g:lsp_diagnostics_signs_enabled = 0

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    nmap <buffer> ga <Cmd>LspCodeAction<CR>
    nmap <buffer> <leader>q <Cmd>LspDocumentDiagnostics --buffers=*<CR>
    nmap <buffer> <leader>f <Cmd>LspDocumentFormat<CR>

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go,*.ts,*.tsx call execute('LspDocumentFormatSync')
endfunction

augroup lsp_install
    au!
    au User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" DeepL
let g:deepl#endpoint = "https://api-free.deepl.com/v2/translate"
let deepl_key = expand("~/.config/nvim/deepl_auth_key.txt")
if file_readable(deepl_key)
  let g:deepl#auth_key = readfile(deepl_key)[0]
endif

" replace a visual selection
vmap t<C-e> <Cmd>call deepl#v("EN")<CR>
vmap t<C-j> <Cmd>call deepl#v("JA")<CR>

" translate a current line and display on a new line
nmap t<C-e> yypV<Cmd>call deepl#v("EN")<CR>
nmap t<C-j> yypV<Cmd>call deepl#v("JA")<CR>

map <C-j> <Plug>(edgemotion-j)
map <C-k> <Plug>(edgemotion-k)

if filereadable('package.json')
  set path=,,~/.vim,src/**,tests/**
else
  set path=,,~/.vim,**
endif

autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact

" fzf
let $FZF_DEFAULT_COMMAND = "fd --type f"
let $FZF_DEFAULT_OPTS = "--layout=reverse --info=inline --bind ctrl-b:page-up,ctrl-f:page-down,ctrl-u:up+up+up,ctrl-d:down+down+down"
let g:previewShell = "bat --style=numbers --color=always --line-range :500"
let g:fzf_custom_options = ['--preview', previewShell.' {}']
let g:fzf_history_dir = '~/.local/share/fzf-history'
autocmd! FileType fzf tnoremap <expr> <C-r> getreg(nr2char(getchar()))
command! W <Nop>
nnoremap <silent> <space>f :<C-u>Files<CR>
nnoremap <silent> <space>h :<C-u>History<CR>
nnoremap <silent> <space>r :<C-u>Rg<CR>

" vsnip
let g:vsnip_filetypes = {}
let g:vsnip_filetypes.javascriptreact = ['javascript']
let g:vsnip_filetypes.typescriptreact = ['typescript']

imap <expr> <C-f> vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)' : '<C-f>'
smap <expr> <C-f> vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)' : '<C-f>'
imap <expr> <C-b> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)' : '<C-b>'
smap <expr> <C-b> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)' : '<C-b>'

" sneak
let g:sneak#label = 1
highlight Sneak guifg=#cc0000 guibg=#000000
highlight link SneakBackground Comment

let g:sneak_background = 0
augroup MySneak
  au!
  au User SneakEnter let g:sneak_background = matchadd('SneakBackground', '.*')
  au User SneakLeave call matchdelete(g:sneak_background)
augroup end

highlight link LspErrorHighlight SpellBad
highlight link LspErrorVirtualText SpellBad
