
if exists('g:loaded_ide_autoload_makefile')
  finish
endif

let g:loaded_ide_autoload_makefile = 1

let s:makefile_wrapper = g:Ide.pluginpath . '/script/makefile.mk'

" Traverses cwd until a Makefile is found
" Returns empty string on failure
function! makefile#lookup(cwd)
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
endfunction

function! makefile#parse(makefile)
  let l:res = {}
  let l:res['CFLAGS'] = makefile#getvar(a:makefile, 'CFLAGS')
  let l:res['CPPFLAGS'] = makefile#getvar(a:makefile, 'CPPFLAGS')

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
  return l:res
endfunction

fun! makefile#getvar(makefile, name)
  let l:vars = {'FILENAME':'null'}
  let l:flags = {
        \'--no-print-directory': v:null,
        \'-f': s:makefile_wrapper,
        \'-C': fnamemodify(a:makefile,':p:h'),
        \}
  let l:target = 'printvar_' . a:name
  let l:cmd = makefile#buildcmd(
        \a:makefile, l:target, l:vars, l:flags)
  return makefile#runcmd_(l:cmd)

  "let l:cmd = "print-var_" . a:name
  "return makefile#runcmd(a:makefile, l:cmd, {})
  "let l:makefile_script  = g:Ide.pluginpath . '/script/makefile.mk'
  "let l:makefile_path = fnamemodify(a:makefile,':p:h')
  "let l:cmd = 'make --no-print-directory -f ' . l:makefile_script
  "let l:cmd.= ' -C ' . l:makefile_path
  "let l:cmd.= ' print-var_-' . a:name
  "
  "let l:res = system(l:cmd)
  "if v:shell_error
  "  echoerr "An error has occurred: " . v:errmsg
  "endif
  "return l:res
endfun

fun! makefile#buildcmd(makefile, target, vars, flags)
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

"fun! makefile#preprocess(makefile, filename)
"  let l:awkfile = g:Ide.pluginpath . '/script/makefile_pp.awk'
"  let l:cmd= makefile#buildcmd(a:makefile,'preprocess_')
"  let l:cmd.=' AWKFILE=' . shellescape(l:awkfile)
"  let l:cmd.=' FILENAME=' . shellescape(a:filename)
"  execute 'silent read !' . l:cmd
"  "return system(l:cmd)
"endfun

"fun! makefile#assemble(makefile, filename)
"  let l:awkfile = g:Ide.pluginpath . '/script/makefile_pp.awk'
"  let l:cmd= makefile#buildcmd(a:makefile,'objdump_')
"  let l:cmd.=' FILENAME=' . shellescape(a:filename)
"  return system(l:cmd)
"endfun
"
fun! makefile#runcmd_(cmd)
  call ide#debugmsg('runcmd', a:cmd)
  let l:res = system(a:cmd)
  if v:shell_error
    echoerr "An error has occurred: " . v:errmsg
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
  let l:cmd = makefile#buildcmd(
        \a:makefile, l:target, l:vars, l:flags)
  return makefile#runcmd_(l:cmd)
endfun

fun! makefile#readcmd(makefile, cmd, vars)
  let l:awkfile = g:Ide.pluginpath . '/script/makefile_pp.awk'
  let l:cmd = "" 

  if !empty(a:vars)
    for key in keys(a:vars)
      let l:cmd .=' ' . key . '=' .shellescape(a:vars[key])
    endfor
  endif

  let l:cmd .= ' ' . makefile#buildcmd(a:makefile,a:cmd . '_')
  "call ide#debugmsg('readcmd', l:cmd)
  execute 'silent read !' . l:cmd
endfun
