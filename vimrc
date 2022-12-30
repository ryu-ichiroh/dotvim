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
set cursorline
set showmode
set backspace=indent,eol,start

colorscheme habamax

let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

packadd vim-jetpack
call jetpack#begin()
  Jetpack 'tani/vim-jetpack', {'opt': 1}

  " denops
  " Jetpack 'vim-denops/denops.vim'
  " Jetpack 'Shougo/ddu.vim'
  " Jetpack 'Shougo/ddu-ui-ff'
  " Jetpack 'Shougo/ddu-kind-file'
  " Jetpack 'Shougo/ddu-filter-matcher_substring'
  " Jetpack 'Shougo/ddu-source-file_rec'
  " Jetpack 'Shougo/ddu-source-file_old'
  " Jetpack 'Shougo/ddu-source-rg'
  " Jetpack 'Shougo/ddu-source-file_external'
  " Jetpack 'Shougo/ddu-source-line'
  " Jetpack 'Shougo/ddu-source-buffer'

  Jetpack 'ryicoh/deepl.vim'
  Jetpack 'justinmk/vim-sneak'
  Jetpack 'haya14busa/vim-edgemotion'

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
  Jetpack 'ryicoh/vim-cspell'

  Jetpack 'jparise/vim-graphql', { 'for': 'graphql' }
  Jetpack 'leafgarland/typescript-vim', { 'for': ['typescript', 'typescriptreact'] }
  Jetpack 'peitalin/vim-jsx-typescript', { 'for': 'typescriptreact' }

  Jetpack 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Jetpack 'junegunn/fzf.vim'

call jetpack#end()

" source <sfile>:h/ddu.vim

let g:lsp_signature_help_delay = 50
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_echo_delay = 50
let g:lsp_diagnostics_float_delay = 50
let g:lsp_diagnostics_float_cursor = 0
let g:lsp_diagnostics_highlights_delay = 50
let g:lsp_diagnostics_signs_delay = 50
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_diagnostics_virtual_text_delay = 50

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

" spelunker
let g:spelunker_disable_auto_group = 1

autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact

" fzf
let $FZF_DEFAULT_OPTS = "--layout=reverse --info=inline --bind ctrl-b:page-up,ctrl-f:page-down,ctrl-u:up+up+up,ctrl-d:down+down+down"
let g:previewShell = "bat --style=numbers --color=always --line-range :500"
let g:fzf_custom_options = ['--preview', previewShell.' {}']
let g:fzf_history_dir = '~/.local/share/fzf-history'
command! W <Nop>
nnoremap <silent> <space>f :<C-u>Files<CR>
nnoremap <silent> <space>h :<C-u>History<CR>
nnoremap <silent> <space>r :<C-u>Rg<CR>

