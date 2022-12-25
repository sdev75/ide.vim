let s:Editor = {}
let g:IdeEditor = s:Editor

" Unique idenifier for the buffer
let s:bufname = "ide_editor"

fun! s:Editor.new(layoutid)
  call g:Ide.debug(3, "Editor.new", "New editor created")
  let l:editor = deepcopy(self)
  let l:editor.layoutid = a:layoutid
  let l:editor.bufnr = -1
  " List of buffers 
  let l:editor.buffers = []
  return l:editor
endfun

fun! s:Editor.init()
  call g:Ide.debug(3, "Editor.init", 
        \ "Initializing editor for layoutid " .. self.layoutid)
  
  " Use a placeholder buffer for all editors (ide_editor)
  let l:bufnr = bufnr(s:bufname)
  if l:bufnr == -1
    execute "silent! new"
    let l:bufnr = bufnr("$")
    call setbufvar(l:bufnr, "&buflisted", 0)
    call setbufvar(l:bufnr, "&number", 1)
    call setbufvar(l:bufnr, "&list", 0)
    execute "silent! file " .. s:bufname
    call win_execute(bufwinid(l:bufnr), "close!")
  endif
endfun
