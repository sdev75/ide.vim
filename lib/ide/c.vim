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
  let l:bufnr = l:widget.getbufnr()
  if l:bufnr == -1
    let l:bufnr = g:IdeBuffer.bufnr('example', 'scratch')
    "call setbufvar(l:bufnr, 'buftype', 'widget')
    call appendbufline(l:bufnr, 0, ["Widget example"])
  endif
  let l:bar = g:Ide.getLayout(l:widget.layout_id).
        \getBar(l:widget.bar_id)
  call win_execute(l:bar.getWinid(), 'sb' . l:bufnr)
  let l:winid = bufwinid(l:bufnr)
  call win_execute(l:winid, 'setlocal nonumber')
  call win_execute(l:winid, 'setlocal nolist')
  let l:widget.bufnr = l:bufnr
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
call g:Ide.getLayout().addWidget('right', s:widget)

