let s:widget = g:IdeWidget.new('objdump_shared')

let s:buf_prefix = 'ide_widget_objdump_'

fun! s:widget.constructor(widget, payload)
  let l:layoutid = a:widget.layoutid
  let l:bar = g:Ide.getLayout(l:layoutid).getBar(a:widget.barid)

  let l:bufname = s:buf_prefix . 'shared'
  let l:bufnr = bufnr(l:bufname)
  if l:bufnr == -1
    execute 'silent! new'
    let l:bufnr = bufnr('$')
    call setbufvar(l:bufnr, "&buflisted", 0)
    call setbufvar(l:bufnr, "widget", 1)
    call setbufvar(l:bufnr, 'number', 0)
    call setbufvar(l:bufnr, 'list', 0)
    execute 'silent! file ' . l:bufname
    call win_execute(bufwinid(l:bufnr), 'close!')
  endif
endfun

fun! s:widget.open(widget, payload)
  let l:layoutid = a:widget.layoutid
  let l:bufname = s:buf_prefix . 'shared'
  let l:bufnr = bufnr(l:bufname)
  let l:barid = a:widget.barid
  let l:bar = g:Ide.getLayout(l:layoutid).getBar(l:barid)
  
  call ide#debugmsg("objdump.open",
        \ " bufnr " . l:bufnr
        \ . " bufname " . l:bufname
        \ . " layoutid " . l:layoutid
        \ . " winid " . bufwinid(l:bufnr)
        \ . " bar.winid " . l:bar.getWinid())
  
  call win_execute(l:bar.getWinid(), 'sb ' . l:bufnr)
endfun

fun! s:widget.close(widget, payload)
  let l:layoutid = a:widget.layoutid
  let l:bufname = s:buf_prefix . 'shared'
  let l:bufnr = bufnr(l:bufname)
  let l:winid = bufwinid(l:bufnr)
  call ide#debugmsg("objdump.close",
        \ " layoutid " . l:layoutid
        \ . " bufname " . l:bufname
        \ . " bufnr " . l:bufnr
        \ . " winid " . l:winid)
  call win_execute(l:winid, 'close!')
endfun

fun! s:widget.getbufnr()
  return s:buf_prefix . 'shared'
endfun

fun! s:widget.update(widget, payload)
  let l:bufname = s:buf_prefix . 'shared'
  let l:bufnr = bufnr(l:bufname)
  call setbufline(l:bufnr, 1, [strftime("%c")])
  call setbufline(l:bufnr, 2, [a:payload.filename])
  call setbufline(l:bufnr, 3, [bufwinid(l:bufnr)])
  
  call win_gotoid(bufwinid(l:bufnr))
  call win_gotoid(bufwinid(l:bufnr))
  "call makefile#assemble(a:payload.makefile, 
  "      \a:payload.filename)
  "call win_gotoid(a:payload.winid)
endfun

call g:Ide.registerWidget(s:widget)

