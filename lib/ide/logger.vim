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
    exe 'silent! new'
    let l:bufnr = bufnr('$')
    call setbufvar(l:bufnr, "&buflisted", 0)
    call setbufvar(l:bufnr, '&number', 0)
    call setbufvar(l:bufnr, '&list', 0)
    exe 'silent! file ' . s:bufname
    call win_execute(bufwinid(l:bufnr), 'close!')
  endif

  let s:constructed = 1
  "call win_execute(bufwinid(l:bufnr),'normal! ggdG')
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
  if type(a:msg) == v:t_func || 
        \ type(a:msg) == v:t_list ||
        \ type(a:msg) == v:t_dict
    let l:msg = string(a:msg)
  else
    let l:msg = a:msg
  endif

  let l:buf = printf("%s [%5s] %15s: %s\n",
        \ l:date, toupper(a:type), a:prefix, l:msg)

  let l:bufnr = bufnr(s:bufname)
  if l:bufnr == -1
    errmsg "The log buffer no longer exist"
    return -1
  endif

  " Ensure the buf is loaded first
  call bufload(l:bufnr)

  " Append line to the buffer (use bufload)
  call appendbufline(l:bufnr, '$', split(l:buf, "\n")) 
  
  if bufwinid(l:bufnr) != -1
    call win_execute(bufwinid(l:bufnr),'normal! G')
  endif
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

fun! s:Logger.log(type, level, prefix, data)
  return self[a:type](a:level, a:prefix, a:data)
endfun
