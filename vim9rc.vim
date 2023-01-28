vim9script

# Options {{{

set nocompatible
set shiftwidth=2
set tabstop=2
set expandtab
set hlsearch
set autoindent
# set signcolumn=yes
set wildmenu
set wildoptions=pum,fuzzy
set ttimeoutlen=30
set updatetime=30
set number
set wildignore=*.dump,*.o,*.tmp
# set completeopt=menuone,noselect,noinsert
set cursorline
set showmode
set backspace=indent,eol,start
set termguicolors
set laststatus=2
set shortmess-=S
set viminfo='10000,<50,s100,h,:100000
# set nowrap

syntax on
colorscheme habamax

map <C-l> <Cmd>nohlsearch<CR>
# inoremap . .<C-x><C-o>

&t_8f ..= "\<Esc>[38;2;%lu;%lu;%lum"
&t_8b ..= "\<Esc>[48;2;%lu;%lu;%lum"
&t_SI ..= "\e[6 q"
&t_EI ..= "\e[2 q"

# }}}

# Plugin Manager {{{

var plugins = {}
var github_url = 'https://github.com/'
var plugins_path = expand('~/.vim/pack/plugins/opt/')

command! PluginInstall InstallPlugin(){
command! -narg=1 PluginUninstall UninstallPlugin(<f-args>)
command! -narg=1 PluginOpen OpenPlugin(<f-args>)
command! PluginClean delete(plugins_path, 'rf')
command! PluginList ListPlugin()

def Plugin(AddAll: func(func(string, dict<any>, ?func)))
  plugins = {}

  AddAll((repo, opts, config = () => ({})) => {
    var parts = split(repo, '/')
    if len(parts) != 2
      throw 'Invalid repository name: ' .. repo
    endif
    if !((has_key(opts, 'tag')    && opts['tag'] != '') ||
       \ (has_key(opts, 'commit') && strlen(opts['commit']) >= 7))
      throw 'Revision is not specified: ' .. repo .. has_key(opts, 'commit')
    endif
    if has_key(plugins, repo)
      throw 'Already added plugin: ' .. repo
    endif

    opts['config'] = config
    opts['repo'] = repo
    var name = split(repo, '/')[1]
    plugins[parts[1]] = opts
  })

  # timer_start(1, (_) => {
    LoadPluginConfigPre()
    InstallPlugin()
    LoadPluginConfig()
  # })
enddef

def InstallPlugin()
  for name in keys(plugins)
    var repo = plugins[name]['repo']
    var path = plugins_path .. name
    var opts = plugins[name]

    if !isdirectory(path)
      echomsg "Installing " .. repo
      system('git clone ' .. github_url .. repo .. ' ' .. path)
      var revision = 'HEAD'
      if has_key(opts, 'tag')
        revision = opts['tag']
      elseif has_key(opts, 'commit')
        revision = opts['commit']
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

def UninstallPlugin(name: string)
  if !has_key(plugins, name)
    throw name .. " not found"
  endif

  var path = plugins_path .. name
  delete(path, 'rf')
  remove(plugins, name)
enddef

def ListPlugin()
  for name in keys(plugins)
    echo '* ' .. plugins[name]['repo']
  endfor
enddef

def OpenPlugin(name: string)
  if !has_key(plugins, name)
    throw name .. " not found"
  endif

  var path = plugins_path .. name
  execute "e " .. path
enddef

def LoadPluginConfigPre()
  for name in keys(plugins)
    var opts = plugins[name]
    if has_key(opts, 'pre')
      var Config = opts['pre']
      Config()
    endif
  endfor
enddef

def LoadPluginConfig()
  for name in keys(plugins)
    var opts = plugins[name]
    if has_key(opts, 'config')
      var Config = opts['config']
      Config()
    endif
  endfor
enddef

# }}}

# Plugins {{{
def OnLSPBufferEnabled()
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
  setlocal omnifunc=lsp#complete

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

  Add('yegappan/lsp', {commit: 'b054bc3'}, () => {
    final lspServers = [
    \   {
    \     'filetype': ['javascript', 'typescript', 'typescriptreact'],
    \     'path': expand('~/.local/share/vim-lsp-settings/servers/typescript-language-server/typescript-language-server'),
    \     'args': ['--stdio'],
    \   },
    \ ]
    g:LspAddServer(lspServers)

    def g:LspConfig()
      nnoremap K <Cmd>LspPeekDefinition<CR>
      nnoremap ]g <Cmd>LspDiagNext<CR>
      nnoremap [g <Cmd>LspDiagPrev<CR>
      nnoremap ]d <Cmd>LspDiagNext<CR>
      nnoremap [d <Cmd>LspDiagPrev<CR>
      setlocal signcolumn=yes
      setlocal tagfunc=lsp#lsp#TagFunc
    enddef
    augroup my-lsp
      au!
      au User LspAttached g:LspConfig()
    augroup end
  })

  # Add('ryuichiroh/vim-lsp', {commit: '21cc8b2'}, () => {
  #   g:lsp_signature_help_enabled = 0
  #   g:lsp_signature_help_delay = 30
  #   g:lsp_diagnostics_echo_cursor = 1
  #   g:lsp_diagnostics_echo_delay = 30
  #   g:lsp_diagnostics_float_cursor = 1
  #   g:lsp_diagnostics_float_delay = 100
  #   g:lsp_diagnostics_float_insert_mode_enabled = 0
  #   g:lsp_diagnostics_virtual_text_enabled = 1
  #   g:lsp_diagnostics_virtual_text_delay = 30
  #   g:lsp_diagnostics_virtual_text_align = 'after'
  #   g:lsp_diagnostics_virtual_text_padding_left = 2
  #   g:lsp_diagnostics_virtual_text_wrap = 'truncate'
  #   g:lsp_diagnostics_virtual_text_only_highest_severity_enabled = 1
  #   g:lsp_diagnostics_highlights_enabled = 1
  #   g:lsp_diagnostics_highlights_delay = 30
  #   g:lsp_diagnostics_signs_enabled = 0
  #   g:lsp_diagnostics_signs_delay = 30
  #   g:lsp_document_code_action_signs_enabled = 0
  #   g:lsp_document_code_action_signs_delay = 30
  #   g:lsp_auto_enable = 0
  #   g:lsp_use_lua = 1
  #   # g:lsp_log_file = '/tmp/vim-lsp.log'
  #   # g:lsp_log_verbose = 1

  #   augroup lsp_install
  #     autocmd!
  #     autocmd User lsp_buffer_enabled OnLSPBufferEnabled()
  #   augroup END

  #   highlight link LspErrorHighlight SpellBad
  #   highlight link LspHintHighlight SpellRare
  #   highlight link LspErrorVirtualText SpellBad
  #   highlight link LspWarningVirtualText SpellCap
  #   highlight link LspInformationVirtualText SpellCap
  #   highlight link LspHintVirtualText SpellRare

  #   call lsp#enable()
  # })

  # Add('mattn/vim-lsp-settings', {commit: '1a5c082'})
  # Add('prabirshrestha/asyncomplete.vim', {commit: '9c76518'}, () => {
  #   g:asyncomplete_popup_delay = 30
  #   g:asyncomplete_min_chars = 2
  #   # g:asyncomplete_matchfuzzy = 0
  #   # g:asyncomplete_auto_completeopt = 1
  #   # g:asyncomplete_log_file = '/tmp/asyncomplete.log'
  # })
  # Add('prabirshrestha/asyncomplete-lsp.vim', {commit: 'cc5247b'})

  # Add('vim-denops/denops.vim', {commit: '44baa06'})
  # Add('Shougo/ddc.vim', {commit: '60acdc1'})
  # Add('Shougo/ddc-matcher_head', {commit: '470cd38'})
  # Add('shun/ddc-source-vim-lsp', {commit: 'fe4f10f'})
  # Add('Shougo/ddc-ui-native', {commit: 'c67a48d'}, () => {
  #   ddc#custom#patch_global('ui', 'native')
  #   ddc#custom#patch_global('sources', ['vim-lsp'])
  #   ddc#custom#patch_global('sourceOptions', {
  #   \ 'vim-lsp': {
  #   \   'matchers': ['matcher_head'],
  #   \   'mark': 'lsp',
  #   \ },
  #   \ })
  #   ddc#enable()
  # })

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
    g:vsnip_extra_mapping = 0
    g:vsnip_sync_delay = 10
    g:vsnip_choice_delay = 30
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
  Add('itchyny/lightline.vim', {'commit': 'b1e91b4'}, () => {
    g:lightline = {'colorscheme': 'PaperColor'}
  })
  Add('chr4/nginx.vim', {'commit': '9969445'})
  Add('mattn/vim-maketable', {'commit': 'd72e73f'})
})

# }}}

# Others {{{

if filereadable('package.json')
  set path=,,~/.vim,src/**,tests/**
else
  set path=,,~/.vim,**
endif

autocmd BufNewFile,BufRead *.tsx set filetype=typescriptreact
autocmd BufNewFile,BufRead *.vimspec set filetype=vim
nmap <leader>s <Nop>

autocmd BufNewFile,BufRead *.go,*.ts,*.tsx setlocal foldmethod=syntax foldlevel=99
autocmd BufNewFile,BufRead *.vim,vimrc setlocal foldmethod=marker

def g:ProfileStart(func: string = '')
  profile start /tmp/vim_profile.txt
  execute printf('profile func %s', empty(func) ? '*' : func)
enddef

# }}}

