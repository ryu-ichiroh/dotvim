vim9script

source $VIMRUNTIME/defaults.vim
set path=.,,~/.vim,src/**
set shiftwidth=2
set shortmess-=S
set expandtab
colorscheme habamax
set number

var start = 0

# find the start of the word
def FindStartCol(): number
  const line = getline('.')
  start = col('.') - 1
  while start > 0 && line[start - 1] =~ '\k'
    start -= 1
  endwhile
  return start
enddef

var timer_id = 0

def CompleteMonths(findstart: number, base: string): any
  if timer_id > 0
    timer_id->timer_stop()
    timer_id = 0
  endif

  if findstart
    return FindStartCol()
  endif

  timer_id = 1000->timer_start((_) => {
    var items = []
    for m in split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec")
      if m =~ '^' .. base
        items->add({'word': m, 'kind': 'ls', 'dup': 0, 'empty': 0, 'icase': 1})
      endif
    endfor

    items->complete(start + 1)
  })

  return -2
enddef

set completeopt=menuone,preview,noselect,noinsert
set completefunc=CompleteMonths

def LspComplete(ch: any, msg: dict<any>)
  echomsg msg
enddef

def Handler(ch: any, msg: any)
enddef

var servers = {}
def g:StartLanguageServer(name: string, cmd: list<string>)
  if servers->has_key(name)
    return
  endif

  const job = job_start(cmd, {
    'in_mode': 'lsp',
    'out_mode': 'lsp',
    'err_mode': 'nl',
    'callback': 'Handler',
  })

  var req = {
    'method': 'initialize',
    'params': {
      'rootUri': 'file://' .. expand('~/.vim'),
      # 'rootUri': 'file://' .. expand('~/workspace/workschool-frontend'),
      'capabilities': [],
    }
  }
  ch_sendexpr(job->job_getchannel(), req, {'callback': function('LspInitialized', [name])})
enddef

def LspInitialized(name: string, ch: any, res: dict<any>)
  echomsg res
  servers[name] = {
    'job': ch->ch_getjob(),
  }
enddef

def g:StopLanguageServer(name: string)
  const job = servers->get(name, {})->get('job', 0)
  job->job_stop()
  servers->remove(name)
enddef

def g:GetLanguageServers(): list<string>
  var names = []
  for name in servers->keys()
    names->add(name)
  endfor
  return names
enddef

def g:TextDocumentDidOpen(name: string, uri: string)
  if !servers->has_key(name)
    return
  endif

  const job = servers->get(name, {})->get('job')
  if !job
    throw name .. ' not running'
  endif

  const req = {
    'method': 'textDocument/didOpen',
    'params': {
      'textDocument': {'uri': uri},
    }
  }

  job->job_getchannel()->ch_sendexpr(req)
enddef

def g:TextDocumentDidChange(name: string, uri: string)
  if !servers->has_key(name)
    return
  endif

  const job = servers->get(name, {})->get('job')
  if !job
    throw name .. ' not running'
  endif

  const req = {
    'method': 'textDocument/didChange',
    'params': {
      'textDocument': {'uri': uri},
      'contentChanges': [{'text': getline(1, '$')->join('\n')}],
    }
  }
  echomsg req

  job->job_getchannel()->ch_sendexpr(req)
enddef

def g:RequestCompletion(name: string, uri: string, line: number, character: number)
  const job = servers->get(name, {})->get('job')
  if !job
    throw name .. ' not running'
  endif

  const req = {
    'method': 'textDocument/completion',
    'params': {
      'textDocument': {'uri': uri},
      'position': {'line': line, 'character': character},
    }
  }
  echomsg req

  ch_sendexpr(job->job_getchannel(), req, {'callback': 'LspComplete'})
enddef

const vim_ls_path = "~/.local/share/vim-lsp-settings/servers/vim-language-server/vim-language-server"
const ts_ls_path = "~/.local/share/vim-lsp-settings/servers/typescript-language-server/typescript-language-server"
augroup Lsp
  au!
  au VimEnter * g:StartLanguageServer('vim', ['sh', '-c', vim_ls_path .. ' --stdio'])
  au VimEnter * g:StartLanguageServer('ts', ['sh', '-c', ts_ls_path .. ' --stdio'])
  au BufNewFile,BufReadPost * g:TextDocumentDidOpen('ts', 'file://' .. expand('%'))
  au TextChanged * g:TextDocumentDidChange('ts', 'file://' .. expand('%'))
augroup end

# 
# echo vim_
