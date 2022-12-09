let s:widgetid = "netrw_shared"
let s:widget = g:IdeWidget.new(s:widgetid)
let s:bufname = "ide_widget_netrw"

fun! s:widget.constructor(widget, payload)
  "call ide#utils#dump([a:widget,a:payload])
  let l:bufnr = bufnr(s:bufname)
  if l:bufnr == -1
    execute 'silent! new'
    let l:bufnr = bufnr('$')
    call setbufvar(l:bufnr, "&buflisted", 0)
    call setbufvar(l:bufnr, '&number', 0)
    call setbufvar(l:bufnr, '&list', 0)
    execute 'silent! file ' . s:bufname

    call win_execute(bufwinid(l:bufnr), 'close!')
  endif
endfun

fun! s:widget.open(widget, payload)
  "call ide#utils#dump([a:widget,a:payload])
  let l:bufnr = bufnr(s:bufname)
  let l:bar   = g:IdeWidgets.getWidgetBar(a:widget)
 
  " Switch bar's window to widget's buffer
  call win_execute(l:bar.getWinid(), "sb " . l:bufnr)
  
  call g:IdeWidgets.setvar(self, "bufnr", l:bufnr)
endfun

fun! s:widget.close(widget, payload)
  call ide#utils#dump([a:widget,a:payload])
endfun

call g:IdeWidgets.register(s:widget)
