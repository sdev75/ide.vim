" ==
" Description: layout manager with functionalities
" Maintainer: github.com/sdev75
" License: MIT
" ==

scriptencoding utf-8
if exists('loaded_ide')
  finish
endif

let loaded_ide = 1

let g:IdeAutoDraw               = get(g:,'IdeAutoDraw', 1)

augroup Ide
  au!
  " Perform routine calls during startup, cleanup and resizing
  au VimEnter    * do User OnIdeInit
  au VimLeavePre * do User OnIdeShutdown
  au VimResized  * do User OnIdeResize
  " Load C library for C and C++ filetypes
  au FileType    c,h          call ide#loadlib('ide/c')
  au FileType    cc,cpp,hpp   call ide#loadlib('ide/cpp')
augroup END

call ide#initCoreFiles()
