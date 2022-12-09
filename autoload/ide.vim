if exists('g:loaded_ide_autoload')
  finish
endif

let g:loaded_ide_autoload = 1

fun! ide#init()
  "runtime lib/ide/buffer.vim
  runtime lib/ide/editor.vim
  runtime lib/ide/editors.vim
  runtime lib/ide/panel.vim
  runtime lib/ide/bar.vim
  runtime lib/ide/bars.vim
  runtime lib/ide/widget.vim
  runtime lib/ide/widgets.vim
  runtime lib/ide/layouts.vim
  runtime lib/ide/layout.vim
  "runtime lib/ide/terminal.vim
  runtime lib/ide/ide.vim
endfun

fun! ide#loadlib(path)
  call ide#debug(3, "ide#loadlib", "Loading lib " . a:path)
  execute 'runtime lib/' . a:path . '.vim'
endfun

fun! ide#loadwidget(path)
  execute 'runtime widget/'. a:path . '.vim'
endfun

fun! ide#scriptloaded(type, path)
  let l:scriptnames = split(execute('scriptnames'), "\n")
  return len(filter(l:scriptnames, 
        \ 'v:val =~ ' . a:type . '/' . a:path . '.vim'))
endfun

fun! ide#debugmsg(prefix, msg)
  if !g:IdeDebugVerbosity
    return
  endif
  if len(a:prefix)
    let l:prefix = " " . a:prefix . ": "
  else
    let l:prefix = " "
  endif
  let l:msg = "[DEBUG]" . l:prefix . a:msg
  if g:IdeDebugVerbosity == 1
    execute "normal! :echom \"" . l:msg . "\"\<CR><CR>"
    return
  endif
  echom l:msg
endfun

" The higher the verbosity the more debugging is provided
fun! ide#debug(level, prefix, msg)
  if a:level > g:IdeDebugVerbosity
    return
  endif
  let l:msg = "[DEBUG:" . a:level . "][" . a:prefix 
        \ . "] " .  a:msg
  if mode() == "V"
    return
  endif
  execute "normal! :echom \"" . l:msg . "\"\<CR><CR>"
endfun

fun! ide#initCommands()
  command! -n=1 IdeToggleBar call g:Ide.toggleBar(<f-args>)
  command! -n=0 IdeToggleTerminal call g:Ide.toggleTerminal()
  command! -n=0 IdeOpenTerminalAndFocus call g:Ide.openTerminalAndFocus()
endfun
