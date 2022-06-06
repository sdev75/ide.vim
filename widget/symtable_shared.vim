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
  call ide#debug(3, "widget.open",
        \ "Open called for " . a:widget.id)

  let l:layout  = g:Ide.getLayout(a:widget.layoutid)
  let l:bar     = l:layout.getBar(a:widget.barid)
  let l:bufnr   = bufnr(s:buf_prefix . "shared")
  
  " Switch bar's window to widget's buffer
  call win_execute(l:bar.getWinid(), 'sb ' . l:bufnr)

  " Draw winbar
  call win_execute(bufwinid(l:bufnr),
        \ "nnoremenu 1.10 WinBar.Symbols :NONE<CR>")
  call self.setvar('bufnr', l:bufnr)
endfun

fun! s:widget.opened()
  doautocmd User IdeWidgetOpen
endfun

fun! s:widget.close(widget, payload)
  call ide#debug(3, "widget.close",
        \ "Close called for " . a:widget.id)
  
  let l:bufnr   = bufnr(s:buf_prefix . "shared")
  call win_execute(bufwinid(l:bufnr), 'close!')
endfun

fun! s:widget.getbufnr()
  return s:buf_prefix . 'shared'
endfun

fun! s:widget.update(widget, payload)
  let l:bufnr = bufnr(s:buf_prefix . "shared")

  call win_execute(bufwinid(l:bufnr),'normal! ggdG')
  call appendbufline(l:bufnr, '$', split(a:payload.buf, "\n")) 
endfun

call g:IdeWidgets.register(s:widget)
call ide#debug(4, "Widget", "Loaded " . s:widgetid)

augroup ide_widget_symtable
  autocmd!
  autocmd User IdeWidgetOpen  call s:try()
  autocmd User IdeCInit     call s:do()
  autocmd BufWritePost *.c  call s:do()
augroup END

fun! s:try()
  call ide#debug(3, "widget.symtable",
        \ "try() invoked")
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
  call ide#debug(3, "widget.symtable",
        \ "Called do_() with " . a:filename)
  
  let l:makefile = g:IdeC.makefile_vars['makefile']
  let l:vars = #{FILENAME:a:filename}
  let l:buf = makefile#runcmd(l:makefile,
        \ 'readelf-symbols_', l:vars)
  let l:payload = #{
        \filename: a:filename,
        \winid: win_getid(),
        \makefile: l:makefile,
        \buf: l:buf
        \}
  call g:IdeWidgets.runEvent(s:widgetid, "update", l:payload)
endfun
