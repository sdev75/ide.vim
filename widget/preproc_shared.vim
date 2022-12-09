let s:widgetid = "preproc_shared"
let s:widget = g:IdeWidget.new(s:widgetid)

let s:bufname = "ide_widget_preproc"

fun! s:widget.constructor(widget, payload)
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

  call g:IdeWidgets.setvar(self, 'minheightpct', 0.5)
endfun

fun! s:widget.open(widget, payload)
  let l:bufnr = bufnr(s:bufname)
  let l:bar   = g:IdeWidgets.getWidgetBar(a:widget)
 
  " Switch bar's window to widget's buffer
  call win_execute(l:bar.getWinid(), "sb " . l:bufnr)

  " Draw winbar
  call win_execute(bufwinid(l:bufnr),
        \ "nnoremenu 1.10 WinBar.CPP :NONE<CR>")
  
  call g:IdeWidgets.setvar(self, "bufnr", l:bufnr)
endfun

fun! s:widget.opened()
  doautocmd User IdeWidgetOpen
endfun

" A possible issue is when the same buffer is used in 
" multiple bars. Closing a widget in one bar will likely
" close all the widgets sharing the same buffer
fun! s:widget.close(widget, payload)
  let l:bufnr   = bufnr(s:bufname)
  call win_execute(bufwinid(l:bufnr), 'close!')
endfun

fun! s:widget.update(widget, payload)
  let l:bufnr = bufnr(s:bufname)
  call win_execute(bufwinid(l:bufnr),'normal! ggdG')
  call appendbufline(l:bufnr, '$', split(a:payload.buf, "\n")) 
endfun

call g:IdeWidgets.register(s:widget)

augroup ide_widget_preproc
  autocmd!
  "autocmd User IdeWidgetOpen  call s:trydisasm()
  "autocmd User IdeCInit       call s:disasm()
  "autocmd BufWritePost *.c,*.cpp,*.cc    call s:disasm()
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
        \ "Disassembling file " . shellescape(a:filename))

  let l:buf = g:IdeC.preprocess(a:filename) 
  let l:payload   = #{
        \ filename: a:filename,
        \ winid: win_getid(),
        \ buf: l:buf
        \ }

  call g:IdeWidgets.runEvent(s:widgetid, "update", l:payload)
endfun

