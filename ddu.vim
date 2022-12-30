nnoremap <space>f <Cmd>Files<CR>
nnoremap <space>v <Cmd>Files ~/.vim/vimrc<CR>
nnoremap <space>r <Cmd>Rg<CR>
nnoremap <space>h <Cmd>History<CR>
nnoremap <space>b <Cmd>Buffers<CR>
nnoremap <space>c <Cmd>History:<CR>
nnoremap <space>/ <Cmd>History/<CR>

call ddu#custom#patch_global({
\ 'ui': 'ff',
\ 'uiParams': {
\   'ff': {
\     'startFilter': v:true,
\   },
\ },
\ 'sourceOptions': {
\   '_': {
\     'matchers': ['matcher_substring'],
\     'ignoreCase': v:true,
\   },
\ },
\ 'filterParams': {
\   'matcher_substring': {
\     'highlightMatched': 'Search',
\   },
\ }
\ })

command! -nargs=? -complete=dir Files call ddu#start({
\ 'name': 'files',
\ 'sources': [
\   {
\     'name': 'file_rec',
\     'params': {
\       'ignoredDirectories': [
\         '.git',
\         'build',
\         '.next',
\         'node_modules',
\         'storybook-static',
\       ],
\     },
\     'options': { 'path': fnamemodify(<q-args>, ':p') },
\   },
\ ]
\ })

command! -nargs=? -complete=dir GFiles call ddu#start({
\ 'name': 'git_files',
\ 'sources': [
\   {
\     'name': 'file_external',
\     'params': {
\       'cmd': ['git', 'ls-files'],
\       'path': fnamemodify(<q-args>, ':p'),
\     },
\   },
\ ]
\ })

command! -nargs=? -complete=dir GStatusFiles call ddu#start({
\ 'name': 'git_status_files',
\ 'sources': [
\   {
\     'name': 'file_external',
\     'params': {
\       'cmd': ['git', 'ls-files', '--modified', '--others', '--exclude-standard'],
\       'path': fnamemodify(<q-args>, ':p'),
\     },
\   },
\ ]
\ })

command! History call ddu#start({
\ 'name': 'history',
\ 'sources': [{ 'name': 'file_old' }]
\ })

command! Buffers call ddu#start({
\ 'name': 'buffer',
\ 'sources': [{ 'name': 'buffer' }]
\ })

command! -nargs=? -complete=dir Rg call ddu#start({
\ 'name': 'rg',
\ 'sources': [
\   {
\     'name': 'rg',
\     'params': {
\       'args': ["--column", "--no-heading", "--color", "never", "--json"],
\       'path': fnamemodify(<q-args>, ':p'),
\     },
\     'options': {
\       'matchers': [],
\     },
\   },
\ ],
\ 'uiParams': {'ff': {
\   'ignoreEmpty': v:false,
\   'autoResize': v:false,
\ }},
\ 'volatile': v:true,
\ })

command! Lines call ddu#start({
\ 'name': 'line',
\ 'sources': [{ 'name': 'line' }]
\ })

autocmd FileType ddu-ff-filter call s:ddu_filter_my_settings()
function! s:ddu_filter_my_settings() abort
  inoremap <buffer> <CR>
  \ <Cmd>call ddu#ui#ff#do_action('itemAction', {'name': 'open'})<CR>

  let b:lexima_disabled = v:true
  inoremap <buffer><nowait> <Esc> <Esc><Cmd>call ddu#ui#ff#do_action('quit')<CR>

  inoremap <buffer> <C-o>
  \ <Cmd>call ddu#ui#ff#do_action('preview')<CR>
  inoremap <buffer> <C-t>
  \ <Cmd>call ddu#ui#ff#do_action(
  \   'itemAction',
  \   {'name': 'open', 'params': {'command': 'tabedit'}})<CR>
  inoremap <buffer> <C-v>
  \ <Cmd>call ddu#ui#ff#do_action(
  \   'itemAction',
  \   {'name': 'open', 'params': {'command': 'vsplit'}})<CR>

  inoremap <buffer> <C-n> <Down><Esc>A
  inoremap <buffer> <C-p> <Up><Esc>A

  inoremap <buffer> <C-j>
  \ <Cmd>call ddu#ui#ff#execute(
  \ "call cursor(line('.')+1,0)<Bar>redraw")<CR>
  inoremap <buffer> <C-k>
  \ <Cmd>call ddu#ui#ff#execute(
  \ "call cursor(line('.')-1,0)<Bar>redraw")<CR>
  inoremap <buffer> <C-f>
  \ <Cmd>call ddu#ui#ff#execute(
  \ "call cursor(line('.')+10,0)<Bar>redraw")<CR>
  inoremap <buffer> <C-b>
  \ <Cmd>call ddu#ui#ff#execute(
  \ "call cursor(line('.')-10,0)<Bar>redraw")<CR>
  inoremap <buffer> <C-d>
  \ <Cmd>call ddu#ui#ff#execute(
  \ "call cursor(line('.')+5,0)<Bar>redraw")<CR>
  inoremap <buffer> <C-u>
  \ <Cmd>call ddu#ui#ff#execute(
  \ "call cursor(line('.')-5,0)<Bar>redraw")<CR>
endfunction

" let g:ddu_history_limit = 10
" let g:ddu_history_dir = fnamemodify('~/.config/nvim/.ddu_history', ':p')
" if !isdirectory(g:ddu_history_dir)
"   echoerr 'ddu_history: '..g:ddu_history_dir..': No such directory'
" end
" 
" autocmd FileType ddu-ff-filter call s:setup_history()
" function! s:setup_history() abort
"   let l:history_file = g:ddu_history_dir . expand('%') . '.txt'
"   if line('$') <= 1 && filereadable(l:history_file)
"     execute "read " .. l:history_file
"   endif
" 
"   autocmd InsertLeave <buffer> call s:store_history()
" endfunction
" 
" function! s:store_history() abort
"   let l:cur_file = expand('%')
"   let l:history_file = g:ddu_history_dir . l:cur_file . '.txt'
"   let l:num_lines = line('$')
"   echomsg l:num_lines
"   echomsg l:num_lines - g:ddu_history_limit
"   let l:offset = 0
"   if l:num_lines - g:ddu_history_limit > 0
"     let l:offset = l:num_lines - g:ddu_history_limit
"   endif
"   let l:lines = getbufline(bufnr('%'), l:offset, l:num_lines)
"   execute writefile(l:lines, l:history_file)
" endfunction
