vim9script

# Options {{{

set nocompatible
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
var plugins_path = expand('~/.vim/pack/plugins/start/')

command! PluginInstall InstallPlugin()
command! PluginClean call delete(plugins_path, 'rf')

def Plugin(AddAll: func(func(string, dict<any>, ?func)))
  plugins = {}

  AddAll((repo, opts, config = () => 1) => {
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

  InstallPlugin()
  LoadPluginConfig()
enddef

def InstallPlugin()
  for repo in keys(plugins)
    var name = split(repo, '/')[1]
    var path = plugins_path .. name
    if isdirectory(path)
      continue
    endif

    system('git clone ' .. github_url .. repo .. ' ' .. path)
    var revision = 'HEAD'
    if has_key(plugins[repo], 'tag')
      revision = plugins[repo]['tag']
    elseif has_key(plugins[repo], 'commit')
      revision = plugins[repo]['commit']
    endif
    system('git -C ' .. path .. ' switch --detach ' .. revision)
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

Plugin((Add: func(string, dict<any>, ?func)) => {
  Add('ryuichiroh/vim-cspell', {tag: 'v0.3'})
  Add('tpope/vim-surround', {tag: 'v2.2'}, () => 1)
})

# }}}
