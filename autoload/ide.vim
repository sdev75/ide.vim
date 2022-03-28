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

fun! ide#initCommands()
  command! -n=1 IdeToggleBar call g:Ide.toggleBar(<f-args>)
endfun
