let s:widgetid = "disasm_shared"
let s:widget = g:IdeWidget.new(s:widgetid)

let s:buf_prefix = 'ide_widget_disasm_'

fun! s:widget.constructor(widget, payload)
  call ide#debug(3, "widget.constructor",
        \ "Constructor called for " . s:widgetid)

  let l:layout    = g:Ide.getLayout(a:widget.layoutid)
  let l:bar       = l:layout.getBar(a:widget.barid)
  let l:bufname   = s:buf_prefix . 'shared'
  let l:bufnr     = bufnr(l:bufname)

  if l:bufnr == -1
    execute 'silent! new'
    let l:bufnr = bufnr('$')
    call setbufvar(l:bufnr, "&buflisted", 0)
    call setbufvar(l:bufnr, '&number', 0)
    call setbufvar(l:bufnr, '&list', 0)
    execute 'silent! file ' . l:bufname

    call win_execute(bufwinid(l:bufnr), 'close!')
  endif

  call self.setvar('minheightpct', 0.5)
endfun

fun! s:widget.open(widget, payload)
  call ide#debug(3, "widget.open",
        \ "Open called for " . a:widget.id)
  
  let l:layout  = g:Ide.getLayout(a:widget.layoutid)
  let l:bar     = l:layout.getBar(a:widget.barid)
  let l:bufnr   = bufnr(s:buf_prefix . "shared")
 
  " Switch bar's window to widget's buffer
  call win_execute(l:bar.getWinid(), "sb " . l:bufnr)

  " Draw winbar
  call win_execute(bufwinid(l:bufnr),
        \ "nnoremenu 1.10 WinBar.Disasm :NONE<CR>")
  call self.setvar('bufnr', l:bufnr)
endfun

fun! s:widget.opened()
  doautocmd User IdeWidgetOpen
endfun

" A possible issue is when the same buffer is used in 
" multiple bars. Closing a widget in one bar will likely
" close all the widgets sharing the same buffer
fun! s:widget.close(widget, payload)
  call ide#debug(3, "widget.close",
        \ "Close called for " . a:widget.id)
  let l:bufnr   = bufnr(s:buf_prefix . "shared")
  call win_execute(bufwinid(l:bufnr), 'close!')
endfun

fun! s:widget.update(widget, payload)
  let l:bufnr = bufnr(s:buf_prefix . "shared")
  call win_execute(bufwinid(l:bufnr),'normal! ggdG')
  call appendbufline(l:bufnr, '$', split(a:payload.buf, "\n")) 
  call s:gotoline()
endfun

fun!s:widget.gotoline(widget, payload)
  let l:bufnr = bufnr(s:buf_prefix . "shared")
  if l:bufnr == -1
    echoerr "widget has an invalid buffer"
    return
  endif
  let l:str = "g/" . expand('%:t') . ":" . line('.') . "$/"
  call win_execute(bufwinid(l:bufnr), 'set hlsearch')
  call win_execute(bufwinid(l:bufnr), l:str)
  call win_execute(bufwinid(l:bufnr), 'setlocal scrolloff=20')
  call win_execute(bufwinid(l:bufnr), 'redraw')
endfun

call g:IdeWidgets.register(s:widget)
call ide#debug(4, "Widget", "Loaded " . s:widgetid)
augroup ide_widget_disasm
  autocmd!
  autocmd User IdeWidgetOpen  call s:trydisasm()
  autocmd User IdeCInit       call s:disasm()
  autocmd BufWritePost *.c    call s:disasm()
  autocmd CursorMoved *.c     call s:gotoline()
augroup END

fun! s:trydisasm()
  call ide#debug(3, "widget.disasm",
        \ "Trydisasm() invoked")
  let l:bufnr = g:Ide.getLayout().getvar('originBufnr', -1)
  let l:ext = fnamemodify(bufname(l:bufnr),':e')
  if l:ext != 'c' | return | endif
  let l:filename = fnamemodify(bufname(l:bufnr), ':p')
  call s:disasm_(l:filename)
endfun

fun! s:disasm()
  let l:filename = expand("%:p")
  call s:disasm_(l:filename) 
endfun

fun! s:disasm_(filename)
  call ide#debug(3, "widget.disasm",
        \ "Disasm called with " . a:filename)

  let l:makefile  = g:IdeC.makefile_vars['makefile']
  let l:vars      = #{FILENAME:a:filename}
  let l:buf       = makefile#runcmd(l:makefile,
        \ 'objdump-dwarf_', l:vars)
  let l:payload   = #{
        \filename: a:filename,
        \winid: win_getid(),
        \makefile: l:makefile,
        \buf: l:buf
        \}

  call g:IdeWidgets.runEvent(s:widgetid, "update", l:payload)
endfun

fun! s:gotoline()
  call g:IdeWidgets.runEvent(s:widgetid, "gotoline", {})
endfun

