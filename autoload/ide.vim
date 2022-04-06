if exists('g:loaded_ide_autoload')
  finish
endif

let g:loaded_ide_autoload = 1

fun! ide#init()
  runtime lib/ide/buffer.vim
  runtime lib/ide/bar.vim
  runtime lib/ide/widget.vim
  runtime lib/ide/layout.vim
  runtime lib/ide/terminal.vim
  runtime lib/ide/ide.vim
endfun

fun! ide#loadlib(path)
  execute 'runtime lib/' . a:path . '.vim'
endfun

fun! ide#loadwidget(path)
  execute 'runtime widget/'. a:path . '.vim'
endfun

fun! ide#debugmsg(prefix, msg)
  if len(a:prefix)
    let l:prefix = " " . a:prefix . ": "
  else
    let l:prefix = " "
  endif
  let l:msg = "[DEBUG]" . l:prefix . a:msg
  execute "normal! :echom \"" . l:msg . "\"\<CR>"
endfun

fun! ide#initCommands()
  command! -n=1 IdeToggleBar call g:Ide.toggleBar(<f-args>)
endfun
