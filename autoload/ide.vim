if exists('g:loaded_ide_autoload')
  finish
endif

let g:loaded_ide_autoload = 1

function! ide#jsonEscape(data)
  " NERDTree contains verbose formatted data
  " Unsetting the data helps to make the printing
  " possible without having to rely on more cleanups
  if exists('g:NERDTree')
    let l:data = deepcopy(a:data)
    for p in l:data
      for [key,val] in items(p)
        if key == "variables"
          for [kk, vv] in items(val)
            if kk == "NERDTree"
              unlet val[kk]
            endif
            if kk == "NERDTreeRoot"
              unlet val[kk]
            endif
          endfor
        endif
      endfor
    endfor
    let l:buf = string(l:data)
  else
    let l:buf = string(a:data)
  endif

  let l:buf = substitute(l:buf,"function('\\([0-9]\\+\\)')",
    \'"function(\1)"','g')
  let l:buf = substitute(l:buf,"'",'"','g')
  let l:buf = escape(l:buf,'"')
  let l:buf = substitute(l:buf,"{...}",'"[{...}]"','g')
  return l:buf
endfunction

function! ide#dump(data)
  let l:buf = ide#jsonEscape(a:data)
  return system('echo "' . l:buf . '" | python -m json.tool')
endfunction

function! ide#init()
  runtime lib/ide/filetree.vim
endfunction
