
if exists('g:loaded_ide_autoload_makefile')
  finish
endif

let g:loaded_ide_autoload_makefile = 1

let s:makefile_wrapper = g:Ide.pluginpath . '/script/makefile.mk'
let s:makefile_awk = g:Ide.pluginpath . '/script/makefile.awk'

" Traverses cwd until a Makefile is found
" Returns empty string on failure
fun! makefile#lookup(cwd)
  let l:cwd = fnamemodify(a:cwd,':s?\/$??')
  let l:maxdepth = 3
  while 1
    let l:filename = l:cwd . "/Makefile"
    if filereadable(l:filename)
      return l:filename
    endif
    let l:cwd = fnamemodify(l:cwd,':h')
    if l:cwd ==# "/" || l:maxdepth == 0
      break
    endif
    let l:maxdepth = l:maxdepth - 1
  endwhile
  return ""
endfun

function! makefile#parse(makefile)
  let l:res = {}
  let l:res['CFLAGS'] = makefile#getvar_(a:makefile, 'CFLAGS')
  let l:res['CPPFLAGS'] = makefile#getvar_(a:makefile, 'CPPFLAGS')

  " parse include directories -I<includedir1> -I<includedir2>
  let l:includedirs = [] 
  call substitute(l:res['CFLAGS'],'-I\([^ ]\+\)','\=add(l:includedirs,submatch(1))','g')
  " skip duplicates
  call uniq(sort(l:includedirs))
  
  let idx = 0
  while idx < len(l:includedirs)
    if l:includedirs[idx][0] != '/'
      let l:includedirs[idx] = fnamemodify(a:makefile,':p:h') . '/' . l:includedirs[idx]
    endif
    let idx = idx + 1
  endwhile

  let l:res['include_paths'] = l:includedirs
  let l:res['makefile'] = a:makefile
  let s:makefile = a:makefile
  return l:res
endfunction

fun! makefile#getvar_(makefile, name)
  let l:vars = {'FILENAME':'null'}
  let l:flags = {
        \'--no-print-directory': v:null,
        \'-f': s:makefile_wrapper,
        \'-C': fnamemodify(a:makefile,':p:h'),
        \}
  let l:target = 'printvar_' . a:name
  let l:cmd = makefile#buildcmd(l:target, l:vars, l:flags)
  return makefile#runcmd_(l:cmd)
endfun

fun! makefile#getvar(name)
  return makefile#getvar_(s:makefile, a:name)
endfun

fun! makefile#buildcmd(target, vars, flags)
  let l:vars = ''
  if !empty(a:vars)
    for key in keys(a:vars)
      let l:vars .=' ' . key . '=' . shellescape(a:vars[key])
    endfor
  endif
  
  let l:flags = ''
  if !empty(a:flags)
    for key in keys(a:flags)
      if a:flags[key] is v:null
        let l:flags .= ' ' . key
        continue
      endif
      let l:flags .=' ' . key . ' ' . shellescape(a:flags[key])
    endfor
  endif

  let l:cmd = l:vars . ' make' . l:flags . ' ' . a:target
  return l:cmd
endfun

fun! makefile#runcmd_(cmd)
  let l:res = system(a:cmd)
  if v:shell_error
   " echoerr An error has occurred: ' . v:errmsg
  endif
  return l:res
endfun

fun! makefile#runcmd(makefile, target, vars)
  let l:vars = a:vars
  let l:flags = {
        \'--no-print-directory': v:null,
        \'-f': s:makefile_wrapper,
        \'-C': fnamemodify(a:makefile,':p:h'),
        \}
  let l:target = a:target
  let l:cmd = makefile#buildcmd(l:target, l:vars, l:flags)
  return makefile#runcmd_(l:cmd)
endfun

fun! makefile#readcmd_(cmd)
  let l:res = system(a:cmd)
  if v:shell_error
   " echoerr An error has occurred: ' . v:errmsg
  endif
  execute 'silent read !' . l:res
endfun

fun! makefile#readcmd(makefile, target, vars)
  let l:vars = a:vars
  let l:flags = {
        \'--no-print-directory': v:null,
        \'-f': s:makefile_wrapper,
        \'-C': fnamemodify(a:makefile,':p:h'),
        \}
  let l:target = a:target
  let l:cmd = makefile#buildcmd(l:target, l:vars, l:flags)
  return makefile#readcmd_(l:cmd)
endfun
