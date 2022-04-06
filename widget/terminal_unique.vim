let s:widget = g:IdeWidget.new('terminal_unique')

let s:buf_prefix = 'ide_widget_term_'

fun! s:widget.constructor(widget)
  " use unique name based on layoutid 
  " each layout might have its own terminal
  let l:layoutid = a:widget.layoutid
  let l:bar = g:Ide.getLayout(l:layoutid).getBar(a:widget.barid)
  " create new empty buffer
  let l:bufname = s:buf_prefix . l:layoutid
  " create a new buffer in a new window and turn it into a terminal
  execute 'new'
  execute 'term ++curwin'
  let l:bufnr = bufnr('$')
  let l:winid = bufwinid(l:bufnr)
  call setbufvar(l:bufnr, "&buflisted", 0)
  call setbufvar(l:bufnr, "terminal", 1)
  call term_setkill(l:bufnr, "kill")
  " rename terminal buffer
  execute 'file ' . l:bufname
  " renaming a terminal always creates a new buffer
  " buffer wipeout erases it
  execute 'bw ' . bufnr('$')
  " close the terminal window
  call win_execute(l:winid, 'close!')
  call ide#debugmsg("terminal.constructor",
        \" bufnr " . l:bufnr
        \." winid " . l:winid 
        \." bar.id " . l:bar.id
        \." bar.winid " . l:bar.winid)
endfun

fun! s:widget.destructor(widget)
  let l:layoutid = a:widget.layoutid
  let l:bar = g:Ide.getLayout(l:layoutid).getBar(a:widget.barid)
  let l:bufname = s:buf_prefix . l:layoutid
  let l:bufnr = bufnr(l:bufname)
  if l:bufnr == -1
    " term_setkill(bufnr, kill) will do the trick
    return
  endif
  call ide#debugmsg("terminal.destructor", "deleting buffer " . l:bufnr)
  execute 'bd! ' . l:bufnr
endfun

fun! s:widget.open(widget)
  let l:layoutid = a:widget.layoutid
  let l:bufname = s:buf_prefix . l:layoutid
  let l:bufnr = bufnr(l:bufname)
  let l:barid = a:widget.barid
  let l:bar = g:Ide.getLayout(l:layoutid).getBar(l:barid)
  call ide#debugmsg("terminal.open",
        \ " bufnr " . l:bufnr
        \ . " bufname " . l:bufname
        \ . " layoutid " . l:layoutid
        \ . " winid " . bufwinid(l:bufnr)
        \ . " bar.winid " . l:bar.getWinid())
  
  call win_execute(l:bar.getWinid(), 'b ' . l:bufnr)
endfun

fun! s:widget.close(widget)
  let l:layoutid = a:widget.layoutid
  let l:bufname = s:buf_prefix . l:layoutid
  let l:bufnr = bufnr(l:bufname)
  let l:winid = bufwinid(l:bufnr)
  call ide#debugmsg("terminal.close",
        \ " layoutid " . l:layoutid
        \ . " bufname " . l:bufname
        \ . " bufnr " . l:bufnr
        \ . " winid " . l:winid)
  "let l:winid = a:widget.getvar('winid',-1)
  call win_execute(l:winid, 'close!')
endfun

call g:Ide.registerWidget(s:widget)

