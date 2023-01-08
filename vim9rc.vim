vim9script

# Options {{{

set nocompatible
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
# set completeopt=menuone,noselect,noinsert
set cursorline
set showmode
set backspace=indent,eol,start
set termguicolors
set foldmethod=marker

syntax on
colorscheme habamax

map <C-l> <Cmd>set nohlsearch<CR>

&t_8f ..= "\<Esc>[38;2;%lu;%lu;%lum"
&t_8b ..= "\<Esc>[48;2;%lu;%lu;%lum"
&t_SI ..= "\e[6 q"
&t_EI ..= "\e[2 q"

# }}}

# Plugins {{{

var plugins = {}
var github_url = 'https://github.com/'
var plugins_path = expand('~/.vim/pack/plugins/opt/')

command! PluginInstall InstallPlugin()
command! PluginClean call delete(plugins_path, 'rf')

def Plugin(AddAll: func(func(string, dict<any>, ?func)))
  plugins = {}

  AddAll((repo, opts, config = () => ({})) => {
    if len(split(repo, '/')) != 2
      throw 'Invalid repository name: ' .. repo
    endif
    if !has_key(opts, 'tag') && !has_key(opts, 'commit')
      throw 'Revision is not specified: ' .. repo
    endif
    if has_key(plugins, repo)
      throw 'Already added plugin: ' .. repo
    endif

    opts['config'] = config
    plugins[repo] = opts
  })

  LoadPluginConfigPre()
  InstallPlugin()
  LoadPluginConfig()
enddef

def InstallPlugin()
  for repo in keys(plugins)
    var name = split(repo, '/')[1]
    var path = plugins_path .. name

    if !isdirectory(path)
      echomsg "Installing " .. repo
      system('git clone ' .. github_url .. repo .. ' ' .. path)
      var revision = 'HEAD'
      if has_key(plugins[repo], 'tag')
        revision = plugins[repo]['tag']
      elseif has_key(plugins[repo], 'commit')
        revision = plugins[repo]['commit']
      endif
      system('git -C ' .. path .. ' switch --detach ' .. revision)
    endif

    execute 'packadd ' .. name
    var doc_path = path .. '/doc'
    if isdirectory(doc_path)
      silent! execute 'helptags ' .. doc_path
    endif
  endfor
enddef

def LoadPluginConfigPre()
  for repo in keys(plugins)
    if has_key(plugins[repo], 'pre')
      var Config = plugins[repo]['pre']
      Config()
    endif
  endfor
enddef

def LoadPluginConfig()
  for repo in keys(plugins)
    if has_key(plugins[repo], 'config')
      var Config = plugins[repo]['config']
      Config()
    endif
  endfor
enddef

def OnLSPBufferEnabled()
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes

  nmap <buffer> gr <plug>(lsp-references)
  nmap <buffer> gi <plug>(lsp-implementation)
  nmap <buffer> <leader>rn <plug>(lsp-rename)
  nmap <buffer> <leader>s <Cmd>LspDocumentSymbol<CR>
  nmap <buffer> [g <plug>(lsp-previous-diagnostic)
  nmap <buffer> ]g <plug>(lsp-next-diagnostic)
  nmap <buffer> K <plug>(lsp-hover)
  nmap <buffer> ga <Cmd>LspCodeAction<CR>
  nmap <buffer> <leader>q <Cmd>LspDocumentDiagnostics --buffers=*<CR>
  nmap <buffer> <leader>f <Cmd>LspDocumentFormat<CR>

  g:lsp_format_sync_timeout = 1000
  autocmd! BufWritePre *.rs,*.go,*.ts,*.tsx call execute('LspDocumentFormatSync')
enddef

Plugin((Add: func(string, dict<any>, ?func)) => {
  Add('justinmk/vim-sneak', {commit: '93395f5', pre: () => {
    g:sneak#label = 1
  }}, () => {
    highlight Sneak guifg=#cc0000 guibg=#000000
    highlight link SneakBackground Comment

    g:sneak_background = 0
    augroup MySneak
      au!
      au User SneakEnter g:sneak_background = matchadd('SneakBackground', '.*')
      au User SneakLeave call matchdelete(g:sneak_background)
    augroup end
  })
  Add('ryuichiroh/vim-cspell', {tag: 'v0.3'})
  Add('ryicoh/deepl.vim', {tag: 'v0.1'}, () => {
    g:deepl#endpoint = "https://api-free.deepl.com/v2/translate"
    var deepl_key = expand("~/.config/nvim/deepl_auth_key.txt")
    if file_readable(deepl_key)
      g:deepl#auth_key = readfile(deepl_key)[0]
    endif

    vmap t<C-e> <Cmd>call deepl#v("EN")<CR>
    vmap t<C-j> <Cmd>call deepl#v("JA")<CR>
    nmap t<C-e> yypV<Cmd>call deepl#v("EN")<CR>
    nmap t<C-j> yypV<Cmd>call deepl#v("JA")<CR>
  })

  Add('tpope/vim-surround', {commit: '3d188ed'})
  Add('tpope/vim-repeat', {commit: '24afe92'})
  Add('tpope/vim-fugitive', {commit: '99cdb88'})
  Add('tpope/vim-commentary', {commit: 'e87cd90'})
  Add('tpope/vim-rhubarb', {commit: 'cad60fe'})

  Add('prabirshrestha/vim-lsp', {commit: '5009876'}, () => {
    g:lsp_signature_help_delay = 50
    g:lsp_diagnostics_echo_cursor = 1
    g:lsp_diagnostics_echo_delay = 50
    g:lsp_diagnostics_float_delay = 100
    g:lsp_diagnostics_float_cursor = 0
    g:lsp_diagnostics_virtual_text_delay = 50
    g:lsp_diagnostics_virtual_text_enabled = 1
    g:lsp_diagnostics_virtual_text_align = 'after'
    g:lsp_diagnostics_virtual_text_padding_left = 2
    g:lsp_diagnostics_virtual_text_wrap = 'truncate'
    g:lsp_diagnostics_highlights_delay = 50
    g:lsp_diagnostics_signs_delay = 50
    g:lsp_diagnostics_signs_enabled = 0

    augroup lsp_install
      autocmd!
      autocmd User lsp_buffer_enabled OnLSPBufferEnabled()
    augroup END

    augroup lsp_folding
      autocmd!
      autocmd FileType go setlocal
        \ foldmethod=expr
        \ foldexpr=lsp#ui#vim#folding#foldexpr()
        \ | setlocal foldlevel=99
    augroup end

    highlight link LspErrorHighlight SpellBad
    highlight link LspErrorVirtualText SpellBad
  })
  Add('mattn/vim-lsp-settings', {commit: '1a5c082'})
  Add('prabirshrestha/asyncomplete.vim', {commit: '9c76518'})
  Add('prabirshrestha/asyncomplete-lsp.vim', {commit: 'cc5247b'})

  Add('junegunn/fzf', { commit: 'fd7fab7' })
  Add('junegunn/fzf.vim', { commit: 'fd7fab7' }, () => {
    $FZF_DEFAULT_COMMAND = "fd --type f"
    $FZF_DEFAULT_OPTS = "--layout=reverse --info=inline --bind ctrl-b:page-up,ctrl-f:page-down,ctrl-u:up+up+up,ctrl-d:down+down+down"
    g:previewShell = "bat --style=numbers --color=always --line-range :500"
    g:fzf_custom_options = ['--preview', g:previewShell .. ' {}']
    g:fzf_history_dir = '~/.local/share/fzf-history'
    autocmd! FileType fzf tnoremap <expr> <C-r> getreg(nr2char(getchar()))
    command! W <Nop>
    nnoremap <silent> <space>f :<C-u>Files<CR>
    nnoremap <silent> <space>h :<C-u>History<CR>
    nnoremap <silent> <space>r :<C-u>Rg<CR>
  })

  Add('hrsh7th/vim-vsnip', { commit: 'e44026b' }, () => {
    g:vsnip_filetypes = {}
    g:vsnip_filetypes.javascriptreact = ['javascript']
    g:vsnip_filetypes.typescriptreact = ['typescript']

    imap <expr> <C-f> vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)' : '<C-f>'
    smap <expr> <C-f> vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)' : '<C-f>'
    imap <expr> <C-b> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)' : '<C-b>'
    smap <expr> <C-b> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)' : '<C-b>'
  })
  Add('hrsh7th/vim-vsnip-integ', { commit: '1cf8990' })
  Add('rafamadriz/friendly-snippets', {commit: '484fb38'})
  Add('vim-test/vim-test', {commit:  '4d6c408'}, () => {
    nmap <silent> <leader>t :TestNearest<CR>
    nmap <silent> <leader>T :TestFile<CR>
    nmap <silent> <leader>a :TestSuite<CR>
    legacy let test#strategy = "vimterminal"
  })
})

# }}}

# Others {{{

if filereadable('package.json')
  set path=,,~/.vim,src/**,tests/**
else
  set path=,,~/.vim,**
endif

autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact
nmap <leader>s <Nop>

# }}}
