let s:widgetid = "terminal"
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
  call g:Ide.debug(3, "widget.open", \
    "Terminal widget openening...")
  "let l:bar = g:IdeWidgets.getWidgetBar(a:widget)
  let l:bufnr = bufnr(s:bufname)

  if l:bufnr == -1
    " A bufnr can become invalid when exiting the terminal by accident or 
    " by choice. This results in undefined behaviour.
    call g:Ide.debug(4, "widget.open",
          \ "Attempting to use an invalid bufnr (-1)")
    "call g:IdeWidgets.setvar(a:widget, "bufnr", -1)
    
    " Destructing the widget as it is no longer in a valid state.
    "call self.run_event('destructor', a:payload)

    " Close the bar as it is left opened when exiting the terminal.
    "call l:bar.close()

    " Toggle the terminal window
    "call g:Ide.toggleTerminal()

    " Signal the caller with an error
    return -1
  endif

  "call win_execute(l:bar.getWinid(), 'b ' . l:bufnr)
  "call g:IdeWidgets.setvar(a:widget, "bufnr", l:bufnr)
endfun

fun! s:widget.close(widget, payload)
  "let l:bufnr = bufnr(s:bufname)
  "let l:winid = bufwinid(l:bufnr)
 " call win_execute(l:winid, 'close!')
endfun

fun! s:widget.onbufcreate(bufnr)
  let bufname = bufname(a:bufnr)
  if bufname ==? s:bufname
    call g:Ide.debug(4, "widget.onbufunload",
          \ "Terminal widget has exited.")
    
    " close the window as it has no valid terminal handle any longer
    let winid = bufwinid(bufnr('%'))
    let win = getwininfo(winid)
    call win_execute(winid, 'close!')
  endif
endfun

call g:IdeWidgets.register(s:widget)

augroup IdeWidgetTerminal
  autocmd!
  autocmd BufCreate * call s:widget.onbufcreate(bufnr())
augroup END
