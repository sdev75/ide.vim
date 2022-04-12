let s:Watcher = {}
let g:IdeCWatcher = s:Watcher

fun! s:Watcher.bufnr()
  let l:bufnr = bufnr('ide_c_watcher')
  if l:bufnr == -1
    let l:bufnr = bufadd('ide_c_watcher')
    call setbufvar(l:bufnr, "&buflisted", 0)
    call setbufvar(l:bufnr, "&buftype", "nofile")
    call setbufvar(l:bufnr, "&swapfile", 0)
    call bufload(l:bufnr)
  endif
  return l:bufnr
endfun

fun! s:Watcher.winid()
  let l:winid = bufwinid('ide_c_watcher')
  return l:winid
endfun

fun! s:Watcher.switchToAsm()
  " get active window
  if self.winid() != -1
    call win_execute(l:winid, 'close')
    return
  endif
 
  let l:bufnr = self.bufnr()
  execute 'vert bel sb' . l:bufnr
endfun

augroup IdeLibCWatcher
  autocmd!
  autocmd BufEnter *.c,*_watcher
        \ nnoremap <buffer><leader>va :call IdeCWatcher.switchToAsm()<cr>
augroup END

