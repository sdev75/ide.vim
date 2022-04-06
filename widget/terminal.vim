let s:widget = g:IdeWidget.new('terminal')

let s:buf_prefix = 'ideterm_widget_layout_'

fun! s:widget.constructor(widget)
  " use unique name based on layoutid 
  " each layout might have its own terminal
  let l:layoutid = a:widget.layoutid
  let l:bar = g:Ide.getLayout(l:layoutid).getBar(a:widget.barid)
  " create new empty buffer
  let l:bufname = s:buf_prefix . l:layoutid
  " init new term within the bar window
  call win_execute(l:bar.getWinid(), 'term ++kill=term') 
  " delete previous buffer as it has been replaced by the terminal
  execute 'bw ' . bufnr('%')
  let l:bufnr = bufnr('$')
 
  call ide#debugmsg("terminal.constructor",
        \" bufnr " . l:bufnr
        \." winid " . bufwinid(l:bufnr)
        \." bar.id " . l:bar.id
        \." bar.winid " . l:bar.winid)
  call setbufvar(l:bufnr, "&buflisted", 0)
  call setbufvar(l:bufnr, "terminal", 1)

  call l:bar.setWinid(bufwinid(l:bufnr))
  call g:IdeBuffer.rename(l:bufnr, l:bufname)
  "call win_execute(bufwinid(l:bufnr),'close!')
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

