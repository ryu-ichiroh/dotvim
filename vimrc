set shiftwidth=2
set tabstop=2
set expandtab
set hlsearch
set autoindent
set signcolumn=yes
set wildoptions=pum
set ttimeoutlen=50
set updatetime=50
set number
set wildignore=*.dump,*.o,*.tmp
set completeopt=menuone,noselect,noinsert
colorscheme habamax

let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

packadd vim-jetpack
call jetpack#begin()
  Jetpack 'tani/vim-jetpack', {'opt': 1}

  " denops
  Jetpack 'vim-denops/denops.vim'
  Jetpack 'Shougo/ddu.vim'
  Jetpack 'Shougo/ddu-ui-ff'
  Jetpack 'Shougo/ddu-kind-file'
  Jetpack 'Shougo/ddu-filter-matcher_substring'
  Jetpack 'Shougo/ddu-source-file_rec'
  Jetpack 'Shougo/ddu-source-file_old'
  Jetpack 'Shougo/ddu-source-rg'
  Jetpack 'Shougo/ddu-source-file_external'
  Jetpack 'Shougo/ddu-source-line'

  Jetpack 'ryicoh/deepl.vim'
  Jetpack 'justinmk/vim-sneak'
  Jetpack 'haya14busa/vim-edgemotion'

  Jetpack 'jparise/vim-graphql'
  Jetpack 'prabirshrestha/vim-lsp'
  Jetpack 'mattn/vim-lsp-settings'
  Jetpack 'prabirshrestha/asyncomplete.vim'
  Jetpack 'prabirshrestha/asyncomplete-lsp.vim'

  Jetpack 'tpope/vim-fugitive'
  Jetpack 'tpope/vim-rhubarb'
  Jetpack 'tpope/vim-surround'
  Jetpack 'tpope/vim-sensible'
  Jetpack 'tpope/vim-commentary'
  Jetpack 'tpope/vim-repeat'
  Jetpack 'kamykn/spelunker.vim'

  Jetpack 'leafgarland/typescript-vim'
  Jetpack 'peitalin/vim-jsx-typescript'

call jetpack#end()

source <sfile>:h/ddu.vim

let g:lsp_signature_help_delay = 100
let g:lsp_diagnostics_echo_delay = 100
let g:lsp_diagnostics_float_delay = 100
let g:lsp_diagnostics_highlights_delay = 100
let g:lsp_diagnostics_signs_delay = 100
let g:lsp_diagnostics_echo_cursor = 1

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
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" DeepL
let g:deepl#endpoint = "https://api-free.deepl.com/v2/translate"
let g:deepl#auth_key = readfile(expand("~/.config/nvim/deepl_auth_key.txt"))[0]

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

" spelunker
let g:spelunker_check_type = 2

autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact
