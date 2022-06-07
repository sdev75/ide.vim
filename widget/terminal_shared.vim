let s:widgetid = "terminal_shared"
let s:widget = g:IdeWidget.new(s:widgetid)
let s:bufname = "ide_widget_term"

fun! s:widget.constructor(widget, payload)
  let l:bufnr = bufnr(s:bufname)
  if l:bufnr == -1
    " create new shared buffer
    execute 'silent! new'
    execute 'silent! term ++curwin'
    
    let l:bufnr = bufnr('$')
    call setbufvar(l:bufnr, "&buflisted", 0)
    call term_setkill(l:bufnr, "kill")
    " rename buffer
    execute 'silent! file ' . s:bufname
    " wipe obsolete buffer
    execute 'silent! bw ' . bufnr('$')
    " close the terminal window
    call win_execute(bufwinid(l:bufnr), 'close!')
  endif
endfun

fun! s:widget.open(widget, payload)
  let l:bar = g:IdeWidgets.getWidgetBar(a:widget)
  let l:bufnr = bufnr(s:bufname)
  call win_execute(l:bar.getWinid(), 'b ' . l:bufnr)
  call g:IdeWidgets.setvar(a:widget, "bufnr", l:bufnr)
endfun

fun! s:widget.close(widget, payload)
  let l:bufnr = bufnr(s:bufname)
  let l:winid = bufwinid(l:bufnr)
  call win_execute(l:winid, 'close!')
endfun

call g:IdeWidgets.register(s:widget)
