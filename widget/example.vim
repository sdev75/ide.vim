" widget example
let s:widget = g:IdeWidget.new('mywidget')
"
fun! s:widget.constructor(widget)
  " abort if getbufnr exists
  let l:bufnr = g:IdeBuffer.bufnr('example', 'scratch')
  call bufload(l:bufnr)
  call setbufline(l:bufnr, 1, ["Widget example"])
  call setbufvar(l:bufnr, 'number', 0)
  call setbufvar(l:bufnr, 'list', 0)
  
  echom "example widget constructed successfully with bufnr " . l:bufnr
endfun
"
fun! s:widget.open(widget)
  " get stored layout instance
  let l:bar = g:Ide.getLayout(a:widget.layoutid)
        \.getBar(a:widget.barid)
  let l:bufnr = g:IdeBuffer.getbufnr('example')
  call win_execute(l:bar.getWinid(), 'sb' . l:bufnr)

  call a:widget.setvar('winid', bufwinid(l:bufnr))
endfun
"
fun! s:widget.close(widget)
  let l:winid = a:widget.getvar('winid',-1)
  call win_execute(l:winid, 'close')
endfun

"call g:Ide.registerWidget(s:widget)
