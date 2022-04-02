"let s:widget = g:IdeWidget.new('terminal')
"fun! s:widget.open(widget)
"  " support for multiple terminal instances
"  let l:widget = a:widget
"  let l:bufnr = l:widget.getbufnr()
"  echo "terminal widget has bufnr: " . l:bufnr
"  if l:bufnr == -1
"    let l:layoutid = g:Ide.getLayout(l:widget.layoutid)
"    call g:IdeTerminal.init(l:layoutid, 'termwidget')
"    return
"  endif
"  execute 'b ' . l:bufnr
"endfun
"
"fun! s:widget.close()
"  echom "widget terminal closing.."
"endfun


"call s:widget.addCallback('open',function('s:widget_open'))
"call s:widget.addCallback('close',function('s:widget_close'))
"call g:Ide.registerWidget(s:widget)
"call g:Ide.getLayout().addWidget('right','terminal')

