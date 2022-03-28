let s:C = {}
let g:IdeC = s:C
let s:filemap = {}

fun! s:C.switchToHeader()
  let l:basename = expand('%:t:r')
  let l:filename = findfile(l:basename . '.h')
  if len(l:filename) == 0
    echoe "Header file '" . l:basename . ".h' not found"
    return
  endif
  let s:filemap[l:filename] = expand('%')
  execute ':e ' . l:filename
endfun

fun! s:C.switchToSource()
  let l:basename = expand('%:t:r')
  let l:filename = findfile(l:basename . '.c')
  if len(l:filename) == 0
    echomsg "Source file '" . l:basename . ".c' not found"
    if has_key(s:filemap, l:filename)
      let l:filename = s:filemap[l:filename]
    endif
  endif
  execute ':e ' . l:filename
endfun

fun! s:C.switchToPreprocessed()
  let l:makefile = self.makefile_vars['makefile']
  let l:filename = expand('%:p')
  call makefile#preprocess(l:makefile,l:filename)
endfun

fun! s:C.init()
  let l:cwd = expand('%:h')
  let l:makefile = makefile#lookup(cwd)
  if len(l:makefile) == 0
    echoerr "Could not find Makefile in directory '" . l:cwd . "'"
    return
  endif
  setlocal path&vim
  let l:makefile_vars = makefile#parse(l:makefile)
  for l:includepath in l:makefile_vars['include_paths']
    execute "setlocal path+=" . l:includepath
  endfor
  let self.makefile_vars = l:makefile_vars
  "let self.makefile_path = fnamemodify(l:parentdir,':p:s?\/$??')
endfun

fun! s:C.getMakefileVars()
  return self.makefile_vars
endfun

augroup IdeLibC_
  autocmd!
  autocmd BufRead,BufEnter,BufWritePost *.c,*.cpp,*.h call s:C.init()
  autocmd BufEnter *.c
        \ nnoremap <buffer><leader>q :call IdeC.switchToHeader()<cr>
  autocmd BufEnter *.h
        \ nnoremap <buffer><leader>q :call IdeC.switchToSource()<cr>
  autocmd BufEnter *.c
        \ nnoremap <buffer><leader>i :call IdeC.switchToPreprocessed()<cr>
augroup END

" widget example
let s:widget = g:IdeWidget.new('mywidget')
fun! s:widget_open(widget)
  let l:widget = a:widget
  let l:bufnr = get(l:widget, 'bufnr', -1)
  if l:bufnr == -1
    let l:bufnr = g:IdeBuffer.bufnr('mkflags','scratch')
    call setbufvar(l:bufnr, 'buftype', 'widget')
    echom l:widget
    let l:widget.bufnr = l:bufnr
    let l:layout = g:Ide.getLayout(l:widget.layout_id)
    let l:bar = l:layout.getBar(l:widget.bar_id)
    echom "winid is " . l:bar.winid
    call win_execute(l:bar.winid, 'b' . l:bufnr)
    call win_execute(l:bar.winid, 'setlocal nonumber')
    call win_execute(l:bar.winid, 'setlocal nolist')
    call appendbufline(l:bufnr, 0, ["Widget example"])
    return
  endif

  call win_execute(l:bar.winid, 'b' . l:bufnr)
endfun
fun! s:widget_close(widget)
endfun
call s:widget.addCallback('open',function('s:widget_open'))
call s:widget.addCallback('close',function('s:widget_close'))
call g:Ide.getLayout().addWidget('right', s:widget)

