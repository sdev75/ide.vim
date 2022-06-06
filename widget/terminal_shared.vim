let s:widget = g:IdeWidget.new('terminal_shared')
let s:buf_prefix = 'ide_widget_term_'

fun! s:widget.constructor(widget, payload)
  let l:layoutid = a:widget.layoutid
  let l:bar = g:Ide.getLayout(l:layoutid).getBar(a:widget.barid)
  
  let l:bufname = s:buf_prefix . 'shared'
  let l:bufnr = bufnr(l:bufname)
  if l:bufnr == -1
    " create new shared buffer
    execute 'silent! new'
    execute 'silent! term ++curwin'
    
    let l:bufnr = bufnr('$')
    call setbufvar(l:bufnr, "&buflisted", 0)
    call setbufvar(l:bufnr, "terminal", 1)
    call term_setkill(l:bufnr, "kill")
    " rename buffer
    execute 'silent! file ' . l:bufname
    " wipe obsolete buffer
    execute 'silent! bw ' . bufnr('$')
    " close the terminal window
    call win_execute(bufwinid(l:bufnr), 'close!')
  endif
 
  call ide#debugmsg("terminal.constructor",
        \" bufnr " . l:bufnr
        \." winid " . bufwinid(l:bufnr)
        \." bar.id " . l:bar.id
        \." bar.winid " . l:bar.winid)
endfun

fun! s:widget.open(widget, payload)
  let l:layoutid = a:widget.layoutid
  let l:bufname = s:buf_prefix . 'shared'
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
  call self.setvar('bufnr', l:bufnr)
endfun

fun! s:widget.close(widget, payload)
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

call g:IdeWidgets.register(s:widget)

