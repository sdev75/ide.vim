let s:widgetid = 'relocs_shared'
let s:widget = g:IdeWidget.new(s:widgetid)

let s:bufname = "ide_widget_relocs"

fun! s:widget.constructor(widget, payload)
  let l:bufnr = bufnr(s:bufname)
  if l:bufnr == -1
    call g:IdeWidgets.newBlankBuffer(s:bufname)
  endif

  call g:IdeWidgets.setvar(self, 'minheightpct', 0.25)
endfun

fun! s:widget.open(widget, payload)
  let l:bufnr = bufnr(s:bufname)
  let l:bar   = g:IdeWidgets.getWidgetBar(a:widget)
  
  call win_execute(l:bar.getWinid(), 'sb ' . l:bufnr)
  call win_execute(bufwinid(l:bufnr),
        \ "nnoremenu 1.10 WinBar.Relocations :NONE<CR>")

  call g:IdeWidgets.setvar(a:widget, "bufnr", l:bufnr)
endfun

fun! s:widget.opened()
  doautocmd User IdeWidgetOpen
endfun

fun! s:widget.close(widget, payload)
  let l:bufnr = bufnr(s:bufname)
  let l:winid = bufwinid(l:bufnr)
  call win_execute(l:winid, 'close!')
endfun

fun! s:widget.update(widget, payload)
  let l:bufnr = bufnr(s:bufname)
  call win_execute(bufwinid(l:bufnr),'normal! ggdG')
  call appendbufline(l:bufnr, '$', split(a:payload.buf, "\n")) 
endfun

call g:IdeWidgets.register(s:widget)

augroup ide_widget_relocs
  autocmd!
  autocmd User IdeWidgetOpen  call s:try()
  autocmd User IdeCInit       call s:do()
  autocmd BufWritePost *.c    call s:do()
augroup END

fun! s:try()
  call ide#debug(4, "widget.relocs", "try() invoked")
  let l:bufnr = g:Ide.getLayout().getvar('originBufnr', -1)
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
  call ide#debug(4, "widget.relocs",
        \ "do_() invoked with " . a:filename)
  
  let l:makefile  = g:IdeC.makefile_vars['makefile']
  let l:vars      = #{FILENAME:a:filename}
  let l:buf       = makefile#runcmd(l:makefile,
        \ 'readelf-relocs_', l:vars)

  let l:payload = #{
        \ filename: a:filename,
        \ winid: win_getid(),
        \ makefile: l:makefile,
        \ buf: l:buf
        \ }
  
  call g:IdeWidgets.runEvent(s:widgetid, "update", l:payload)
endfun
