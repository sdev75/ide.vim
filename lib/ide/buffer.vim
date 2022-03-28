let s:Buffer = {}
let g:IdeBuffer = s:Buffer

let s:map = {}

fun! s:Buffer.scratch()
  let l:bufnr = bufadd('')
  call setbufvar(l:bufnr, "&buftype", "nofile")
  call setbufvar(l:bufnr, "&bufhidden", "hide")
  call setbufvar(l:bufnr, "&swapfile", 0)
  call setbufvar(l:bufnr, "&buflisted", 0)
  call setbufvar(l:bufnr, "&filetype", "idebuf")
  return l:bufnr
endfun

fun! s:Buffer.create(name,type)
  let l:bufnr = self[a:type]()
  let s:map[a:name] = l:bufnr
  return l:bufnr
endfun

fun! s:Buffer.delete(name)
  execute 'bd! ' . s:map[a:name]
  unlet s:map[a:name]
endfun

fun! s:Buffer.bufnr(name, type)
  if has_key(s:map, a:name)
    let l:bufnr = bufnr(s:map[a:name])
    if l:bufnr != -1
      return l:bufnr
    endif
  endif
  return self.create(a:name, a:type)
endfun

fun! s:Buffer.setbufnr(name, bufnr)
  let s:map[a:name] = a:bufnr
endfun

fun! s:Buffer.getbufnr(name)
  if has_key(s:map, a:name)
    return bufnr(s:map[a:name])
  endif
  return -1
endfun

fun! s:Buffer.name(layout, prefix, name)
  return 'ide_' . a:layout . '_' . a:prefix . ' ' . a:name
endfun
