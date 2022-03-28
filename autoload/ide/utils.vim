if exists('g:loaded_ide_utils_autoload')
  finish
endif

let g:loaded_ide_utils_autoload = 1

fun! ide#utils#dump_list(list, lvl)
  echo repeat(' ', a:lvl) . '['
  for i in range(0, len(a:list)-1)
    if i > 0 && i < len(a:list)
      echo repeat(' ', a:lvl) . '-----------'
    endif
    call ide#utils#dump_item(a:list[i],a:lvl+1)
  endfor
  echo repeat(' ', a:lvl) . ']'
endfun

fun! ide#utils#dump_pair(key, val, lvl)
  if type(a:val) == v:t_string
    echo repeat(' ', a:lvl) . a:key . ": '" .  a:val . "'"
    return
  endif
  echo repeat(' ', a:lvl) . a:key . ': ' .  a:val
endfun

fun! ide#utils#dump_dict(dict, lvl)
  for [key, val] in items(a:dict)
    if type(val) != v:t_list && type(val) != v:t_dict
      call ide#utils#dump_pair(key, val, a:lvl)
      continue
    endif
    echo repeat(' ', a:lvl) . key . ':'
    call ide#utils#dump_item(val, a:lvl+1)
  endfor
endfun

fun! ide#utils#dump_item(item, lvl)
  if type(a:item) == v:t_list
    if !len(a:item)
      echo repeat(' ', a:lvl) . '[]' | return
    endif
    call ide#utils#dump_list(a:item, a:lvl+1)
    return
  endif
  if type(a:item) == v:t_dict
    if !len(keys(a:item))
      echo repeat(' ', a:lvl) . '{}' | return
    endif
    call ide#utils#dump_dict(a:item,a:lvl+1)
    return
  endif
  if type(a:item) == v:t_func
    echo repeat(' ', a:lvl) . 'fn: ' . a:item
    return
  endif
  echo repeat(' ', a:lvl) . a:item
endfun

fun! ide#utils#dump(data)
  call ide#utils#dump_item(a:data,-1)
endfun

