let s:widgetid = 'symtable_shared'
let s:buf_prefix = 'ide_widget_symtable_'
let s:widget = g:IdeWidget.new(s:widgetid)

fun! s:widget.constructor(widget, payload)
  let l:layoutid = a:widget.layoutid
  let l:bar = g:Ide.getLayout(l:layoutid).getBar(a:widget.barid)
  
  let l:bufname = s:buf_prefix . 'shared'
  let l:bufnr = bufnr(l:bufname)
  if l:bufnr == -1
    call ide#newBlankBuffer(l:bufname)
  endif

  call self.setvar('minheightpct', 0.25)
endfun

fun! s:widget.open(widget, payload)
  let l:layoutid = a:widget.layoutid
  let l:bufname = s:buf_prefix . 'shared'
  let l:bufnr = bufnr(l:bufname)
  let l:barid = a:widget.barid
  let l:bar = g:Ide.getLayout(l:layoutid).getBar(l:barid)

  call ide#debugmsg("symtable.open",
        \ " bufnr " . l:bufnr
        \ . " bufname " . l:bufname
        \ . " layoutid " . l:layoutid
        \ . " winid " . bufwinid(l:bufnr)
        \ . " bar.winid " . l:bar.getWinid())
  
  call win_execute(l:bar.getWinid(), 'sb ' . l:bufnr)
  let l:winbar = "nnoremenu 1.10 WinBar.Symbols :NONE<CR>"
  call win_execute(bufwinid(l:bufnr), l:winbar)
  "call self.setHeightPct(bufwinid(l:bufnr), 0.25)
endfun

fun! s:widget.opened()
  doautocmd User IdeWidgetOpen
endfun

fun! s:widget.close(widget, payload)
  let l:layoutid = a:widget.layoutid
  let l:bufname = s:buf_prefix . 'shared'
  let l:bufnr = bufnr(l:bufname)
  let l:winid = bufwinid(l:bufnr)
  call ide#debugmsg("symtable.close",
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

  call win_execute(bufwinid(l:bufnr),'normal! ggdG')
  call appendbufline(l:bufnr, '$', split(a:payload.buf, "\n")) 
endfun

call g:IdeWidget.register(s:widget)

if !empty(g:IdeWidget.get(s:widgetid))
augroup ide_widget_symtable
  autocmd!
  "autocmd User IdeWidgetOpen call s:try()
  autocmd User IdeCInit call s:do()
  autocmd BufWritePost *.c  call s:do()
augroup END

fun! s:try()
  let l:bufnr = g:Ide.getLayout().getvar('originBufnr', -1)
  echom bufname(l:bufnr)
  let l:ext = fnamemodify(bufname(l:bufnr),':e')
  if l:ext != 'c' | return | endif
  let l:filename = fnamemodify(bufname(l:bufnr), ':p')
  call s:do_(l:filename)
endfun

fun! s:do()
  let l:filename = expand("%:p")
  call s:do_(l:filename) 
endfun

fun! s:do_(filename)
  let l:widgets = g:Ide.getWidgets()
  let l:widget = l:widgets[s:widgetid][0]
 
  let l:barid = g:Ide.getLayout().getBarId(l:widget.position)
  let l:widget = g:Ide.getLayout()
        \.getBar(l:barid).getWidget(s:widgetid)
  let l:makefile = g:IdeC.makefile_vars['makefile']
  let l:vars = #{FILENAME:a:filename}
  let l:buf = makefile#runcmd(l:makefile, 'readelf-syms_', l:vars)
  let l:payload = #{
        \filename: a:filename,
        \winid: win_getid(),
        \makefile: l:makefile,
        \buf: l:buf
        \}
  call l:widget.run_event('update', l:payload)
endfun
endif
