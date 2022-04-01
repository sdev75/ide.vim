" widget example
let s:widget = g:IdeWidget.new('mywidget')
fun! s:widget_open(widget)
  let l:widget = a:widget
  let l:bufnr = l:widget.getbufnr()
  if l:bufnr == -1
    let l:bufnr = g:IdeBuffer.bufnr('example', 'scratch')
     call bufload(l:bufnr)
    "call setbufvar(l:bufnr, 'buftype', 'widget')
    call setbufline(l:bufnr, 1, ["Widget example"])
  endif
  echom "bufnr for widget is " . l:bufnr
  let l:bar = g:Ide.getLayout(l:widget.layoutid).
        \getBar(l:widget.barid)
  call win_execute(l:bar.getWinid(), 'sb' . l:bufnr)
  echom "bufnr is " . l:bufnr

  let l:winid = bufwinid(l:bufnr)
  echo "winid by bufwinid is " . l:winid
  "call win_execute(l:winid, 'setlocal nonumber')
  "call win_execute(l:winid, 'setlocal nolist')
  let l:widget.winid = l:winid
endfun
fun! s:widget_close(widget)
  let l:widget = a:widget
  echom "Closing widget id " . l:widget.id
  echom "Window id is " . l:widget.winid
  call win_execute(l:widget.winid, 'close')
endfun
call s:widget.addCallback('open',function('s:widget_open'))
call s:widget.addCallback('close',function('s:widget_close'))
"call g:Ide.getLayout().addWidget('right', s:widget)
call g:Ide.registerWidget(s:widget)
call g:Ide.getLayout().addWidget('right','mywidget')
