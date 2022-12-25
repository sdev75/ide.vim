if exists('g:loaded_ide_autoload')
  finish
endif

let g:loaded_ide_autoload = 1

fun! ide#initCoreFiles()
  runtime lib/ide/editor.vim
  runtime lib/ide/editors.vim
  runtime lib/ide/panel.vim
  runtime lib/ide/bar.vim
  runtime lib/ide/bars.vim
  runtime lib/ide/widget.vim
  runtime lib/ide/widgets.vim
  runtime lib/ide/layout_config.vim
  runtime lib/ide/layouts.vim
  runtime lib/ide/layout.vim
  runtime lib/ide/ide.vim
endfun

fun! ide#loadlib(path)
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

fun! ide#initCommands()
  command! -n=0 IdeTogglePanel call g:Ide.togglePanel()
  command! -n=0 IdeToggleLeftBar call g:Ide.toggleLeftBar()
  command! -n=0 IdeToggleRightBar call g:Ide.toggleRightBar()
"  command! -n=1 IdeToggleBar call g:Ide.toggleBar(<f-args>)
"  command! -n=0 IdeToggleTerminal call g:Ide.toggleTerminal()
"  command! -n=0 IdeOpenTerminalAndFocus call g:Ide.openTerminalAndFocus()
endfun
