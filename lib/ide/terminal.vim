let s:Terminal = {}
let g:IdeTerminal = s:Terminal

fun! s:Terminal.init(layout_id, name)
  let l:name = g:IdeBuffer.name(a:layout_id, 'term', a:name)
  let l:bufnr = g:IdeBuffer.getbufnr(l:name)
  echom "bufnr is " . l:bufnr
  if l:bufnr != -1
    execute 'b ' . l:bufnr
    return
  endif
  execute 'term ++curwin ++kill=term'
  let l:bufnr = bufnr('%')
  call setbufvar(l:bufnr, "&buflisted", 0)
  call setbufvar(l:bufnr, "&filetype", "ideterm")
  call setbufvar(l:bufnr, "ideterm", l:name)
  call g:IdeBuffer.setbufnr(l:name, l:bufnr)
endfun

fun! s:Terminal.destroy(layout_id, name)
  let l:name = g:IdeBuffer.name(a:layout_id, 'term', a:name)
  call g:IdeBuffer.delete(l:name)
endfun
