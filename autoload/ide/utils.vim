if exists('g:loaded_ide_utils_autoload')
  finish
endif

let g:loaded_ide_utils_autoload = 1

fun! ide#utils#dump_list(list, lvl)
  echom repeat(' ', a:lvl) . '['
  for i in range(0, len(a:list)-1)
    if i > 0 && i < len(a:list)
      echom repeat(' ', a:lvl) . '-----------'
    endif
    call ide#utils#dump_item(a:list[i],a:lvl+1)
  endfor
  echom repeat(' ', a:lvl) . ']'
endfun

fun! ide#utils#dump_pair(key, val, lvl)
  if type(a:val) == v:t_string
    echom repeat(' ', a:lvl) . a:key . ": '" .  a:val . "'"
    return
  endif
  echom repeat(' ', a:lvl) . a:key . ': ' .  a:val
endfun

fun! ide#utils#dump_dict(dict, lvl)
  for key in keys(a:dict)
    if type(a:dict[key]) == v:t_func
      echom repeat(' ', a:lvl) . l:key . ': fn()' 
      continue
    endif
    let l:value = a:dict[key]
    if type(l:value) != v:t_list && type(l:value) != v:t_dict
      call ide#utils#dump_pair(key, l:value, a:lvl)
      continue
    endif
    echom repeat(' ', a:lvl) . l:key . ':'
    call ide#utils#dump_item(l:value, a:lvl+1)
  endfor
endfun

fun! ide#utils#dump_item(item, lvl)
  
  " List
  if type(a:item) == v:t_list
    if !len(a:item)
      echom repeat(' ', a:lvl) . '[]' | return
    endif
    echom repeat(' ', a:lvl) . "["
    call ide#utils#dump_list(a:item, a:lvl+1)
    echom repeat(' ', a:lvl) . "}"
    return
  endif

  " Dictionary
  if type(a:item) == v:t_dict
    if !len(keys(a:item))
      echom repeat(' ', a:lvl+1) . '{}' | return
    endif
    echom repeat(' ', a:lvl) . "{"
    call ide#utils#dump_dict(a:item,a:lvl+2)
    echom repeat(' ', a:lvl) . "}"
    return
  endif

  " Function
  if type(a:item) == v:t_func
    echom repeat(' ', a:lvl) . 'fn() ' . a:item
    return
  endif
  echom repeat(' ', a:lvl) . a:item
endfun

fun! ide#utils#dump(data)
  call ide#utils#dump_item(a:data,-1)
endfun

