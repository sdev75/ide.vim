let s:Logger = {}
let g:IdeLogger = s:Logger
let s:bufname = "ide_logger"
let s:constructed = 0
let s:verbosity = 1

" Create logger
" A buffer is created unless it exists
fun! s:Logger.constructor()
  let l:bufnr = bufnr(s:bufname)
  if l:bufnr == -1
    execute 'silent! new'
    let l:bufnr = bufnr('$')
    call setbufvar(l:bufnr, "&buflisted", 0)
    call setbufvar(l:bufnr, '&number', 0)
    call setbufvar(l:bufnr, '&list', 0)
    execute 'silent! file ' . s:bufname
  endif

  "call win_execute(bufwinid(l:bufnr), 'close!')
  let s:constructed = 1
  call win_execute(bufwinid(l:bufnr),'normal! ggdG')
endfun

fun! s:Logger.setVerbosityLevel(level)
  let s:verbosity = a:level
endfun

fun! s:Logger.add(type, level, prefix, msg)
  if s:constructed == 0
    " Construct the logger and self-modify the method
    " to save on logic on future calls
    call self.constructor()
    let self.add = self.add_
  endif
  call self.add(a:type, a:level, a:prefix, a:msg)
endfun

fun! s:Logger.add_(type, level, prefix, msg)
  if a:level > s:verbosity
    return
  endif
  
  let l:date = strftime("%c")
  let l:buf = l:date . " | [" . toupper(a:type) . "]" . 
        \ "[" . a:prefix . "]" .
        \ " " . a:msg

  let l:bufnr = bufnr(s:bufname)
  if l:bufnr == -1
    errmsg "The log buffer no longer exist"
    return -1
  endif
  call appendbufline(l:bufnr, '$', split(l:buf, "\n")) 
endfun

fun! s:Logger.info(level, prefix, msg)
  return self.add("info", a:level, a:prefix, a:msg)
endfun

fun! s:Logger.warn(level, prefix, msg)
  return self.add("warn", a:level, a:prefix, a:msg)
endfun

fun! s:Logger.error(level, prefix, msg)
  return self.add("error", a:level, a:prefix, a:msg)
endfun

fun! s:Logger.debug(level, prefix, msg)
  return self.add("debug", a:level, a:prefix, a:msg)
endfun
