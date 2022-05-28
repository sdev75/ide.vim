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
    call setbufvar(l:bufnr, '&number', 0)
    call setbufvar(l:bufnr, '&list', 0)
    execute 'silent! file ' . l:bufname

    call win_execute(bufwinid(l:bufnr), 'close!')
  endif

  call self.setvar('minheightpct', 0.5)
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
  let l:winbar = "nnoremenu 1.10 WinBar.Assembly :NONE<CR>"
  call win_execute(bufwinid(l:bufnr), l:winbar)
  call self.setvar('bufnr', l:bufnr)
endfun

fun! s:widget.opened()
  doautocmd User IdeWidgetOpen
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

  call win_execute(bufwinid(l:bufnr),'normal! ggdG')
  call appendbufline(l:bufnr, '$', split(a:payload.buf, "\n")) 
"  call append(l:bufnr, split(a:payload.buf, "\n"))
  "call setbufline(l:bufnr, 4, [a:payload.buf])
  "call makefile#assemble(a:payload.makefile, 
  "      \a:payload.filename)
  "call win_gotoid(a:payload.winid)
endfun

call g:IdeWidget.register(s:widget)

if !empty(g:IdeWidget.get('objdump_shared'))
augroup ide_lib_c_objdump
  autocmd!
  autocmd User IdeWidgetOpen call s:trydisasm()
  autocmd User IdeCInit call s:disasm()
  autocmd BufWritePost *.c  call s:disasm()
  autocmd CursorMoved *.c call s:gotoline()
augroup END

fun! s:trydisasm()
  "if !has_key(g:Ide.getLayout(), 'mainBufnr')
  "  return
  "endif
  "let l:bufnr = g:Ide.getLayout().mainBufnr
  let l:bufnr = g:Ide.getLayout().getvar('originBufnr', -1)
  let l:ext = fnamemodify(bufname(l:bufnr),':e')
  if l:ext != 'c' | return | endif
  call ide#debugmsg("trydisasm", "mainbufnr is " . l:bufnr) 
  let l:filename = fnamemodify(bufname(l:bufnr), ':p')
  call s:disasm_(l:filename)
endfun

fun! s:disasm()
  let l:filename = expand("%:p")
  call s:disasm_(l:filename) 
endfun

fun! s:disasm_(filename)
  let l:widgets = g:Ide.getWidgets()
  let l:widget = l:widgets['objdump_shared'][0]
 
  let l:barid = g:Ide.getLayout().getBarId(l:widget.position)
  let l:widget = g:Ide.getLayout()
        \.getBar(l:barid).getWidget('objdump_shared')
  let l:makefile = g:IdeC.makefile_vars['makefile']
  let l:vars = #{FILENAME:a:filename}
  let l:buf = makefile#runcmd(l:makefile, 'objdump-dwarf_', l:vars)
  let l:payload = #{
        \filename: a:filename,
        \winid: win_getid(),
        \makefile: l:makefile,
        \buf: l:buf
        \}
  call l:widget.run_event('update', l:payload)
  call s:gotoline()
endfun

fun! s:gotoline()
  let l:widgets = g:Ide.getWidgets()
  let l:widget = l:widgets['objdump_shared'][0]
  let l:barid = g:Ide.getLayout().getBarId(l:widget.position)
  let l:widget = g:Ide.getLayout()
        \.getBar(l:barid)
        \.getWidget('objdump_shared')
  let l:bufnr = bufnr(l:widget.getbufnr())
  if l:bufnr == -1
    return
  endif
  let l:str = "g/" . expand('%:t') . ":" . line('.') . "$/"
  call win_execute(bufwinid(l:bufnr), 'set hlsearch')
  call win_execute(bufwinid(l:bufnr), l:str)
  call win_execute(bufwinid(l:bufnr), 'setlocal scrolloff=20')
  call win_execute(bufwinid(l:bufnr), 'redraw')
endfun
endif
