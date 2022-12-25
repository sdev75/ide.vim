" widget example
let s:bufname = "mywidget_buf"
let s:widget = g:IdeWidget.new('mywidget')

" Widget constructor
" This is called when constructing the widget
" Useful for creating buffers or assiging to existing ones
fun! s:widget.constructor(widget, payload)
  let l:bufnr = bufnr(s:bufname)
  if l:bufnr == -1
    exe 'silent! new'
    let l:bufnr = bufnr('$')
    call setbufvar(l:bufnr, '&buflisted', 0)
    call setbufvar(l:bufnr, '&number', 0)
    call setbufvar(l:bufnr, '&list', 0)
    call bufload(l:bufnr)
    call setbufline(l:bufnr, 1, ["Widget example"])
    exe 'silent! file ' .. s:bufname
    call win_execute(bufwinid(l:bufnr), 'close!')
    
    call g:Ide.debug(3, "Widget.constructor",
          \ "Example widget constructed with bufnr" .. l:bufnr)
    return
  endif
endfun

fun! s:widget.update(widget, payload)
  call g:Ide.debug(3, "widget.update",
        \ "Example widget update invoked with payload: " ..
        \ string(a:payload))
endfun

fun! s:widget.destructor(widget, payload)
  call g:Ide.debug(3, "widget.destructor",
        \ "Example widget update invoked with payload: " ..
        \ string(a:payload))
endfun

call g:IdeWidgets.register(s:widget)
