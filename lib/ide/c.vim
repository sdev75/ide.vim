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
  let l:srcbufnr = getbufvar(bufnr('%'), 'srcbufnr')
  if len(l:srcbufnr) != 0
    execute 'b ' . l:srcbufnr
    return
  endif
  
  let l:srcbufnr = bufnr('%')
  let l:makefile = self.makefile_vars['makefile']
  let l:filename = expand('%:p')

  let l:bufnr = bufnr('ide_c_pp')
  if l:bufnr == -1
    let l:bufnr = bufadd('ide_c_pp')
    call setbufvar(l:bufnr, "&buflisted", 0)
    call setbufvar(l:bufnr, "&buftype", "nofile")
    call setbufvar(l:bufnr, "&swapfile", 0)
    call bufload(l:bufnr)
  endif

  call setbufvar(l:bufnr, "&filetype", 'c')
  call setbufvar(l:bufnr, "srcbufnr", l:srcbufnr)
  execute 'b ' . l:bufnr
  call makefile#preprocess(l:makefile, l:filename)
endfun

fun! s:C.switchToAssembly()
  " return to source code if bufname var is present
  let l:bufname = getbufvar(bufnr('%'), 'bufname')
  if len(l:bufname) != 0
    execute 'e ' . l:bufname
    return
  endif
  
  " get buffer and switch to it
  let l:filename = expand("%:p")
  let l:bufnr = self.getAsmSharedBuf(l:filename)
  execute 'b ' . l:bufnr
  
  " run objdump and print to buffer
  let l:makefile = self.makefile_vars['makefile']
  call makefile#assemble(l:makefile, l:filename)
endfun

fun! s:C.getAsmSharedBuf(filename)
  let l:bufnr = bufnr('ide_c_asm')
  if l:bufnr == -1
    let l:bufnr = bufadd('ide_c_asm')
    call setbufvar(l:bufnr, "&buflisted", 0)
    call setbufvar(l:bufnr, "&buftype", "nofile")
    call setbufvar(l:bufnr, "&swapfile", 0)
    call bufload(l:bufnr)
  endif

  call setbufvar(l:bufnr, "&filetype", 'asm')
  call setbufvar(l:bufnr, "bufname", a:filename)
  return l:bufnr
endfun

fun! s:C.init()
  let l:cwd = expand('%:p:h')
  let l:makefile = makefile#lookup(cwd)
  if len(l:makefile) == 0
    "echoerr "Could not find Makefile in directory '" . l:cwd . "'"
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

fun! s:C.getMakefileVar(name, default)
  return get(self.makefile_vars, a:name, a:default)
endfun

fun! s:C.runMakefile(target, vars)
  let l:makefile = self.getMakefileVar('makefile', -1)
  if l:makefile == -1
    echoerr "Makefile variable is NOT set"
    return -1
  endif

  return makefile#runcmd(l:makefile, a:target, a:vars)
endfun

fun! s:C.disassemble(filename)
  call ide#debug(3, "ide.c",
        \ "Calling disassemble()_ with " 
        \. shellescape(a:filename))

  let l:makefile = self.getMakefileVar('makefile', -1)
  let l:vars = #{
        \ FILENAME: a:filename
        \ }

  let l:buf = self.runMakefile("objdump-dwarf_", l:vars)
  return l:buf
endfun

fun! s:C.initWidgets()
endfun

augroup IdeLibC
  autocmd!
  autocmd BufEnter *.c,*.cpp,*.h call IdeC.initWidgets()
  autocmd BufRead,BufEnter,BufWritePost *.c,*.cpp,*.h call IdeC.init()
  autocmd BufEnter *.c
        \ nnoremap <buffer><leader>s :call IdeC.switchToHeader()<cr>
  autocmd BufEnter *.h
        \ nnoremap <buffer><leader>s :call IdeC.switchToSource()<cr>
  autocmd BufEnter *.c,*_pp
        \ nnoremap <buffer><leader>i :call IdeC.switchToPreprocessed()<cr>
  autocmd BufEnter *.c,*_asm
        \ nnoremap <buffer><leader>a :call IdeC.switchToAssembly()<cr>
augroup END

