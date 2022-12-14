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

" 0 = left bar
" 1 = right bar
" 2 = bottom bar
" 3 = left and right
let g:IdeBarMinWidthPctLeft     = get(g:, 'IdeBarMinWidthPctLeft', 15)
let g:IdeBarMinWidthPctBottom   = get(g:, 'IdeBarMinWidthPctBottom', 7)
let g:IdeBarMinWidthPctTop      = get(g:, 'IdeBarMinWidthPctTop', 10)
let g:IdeBarMinWidthPctRight    = get(g:, 'IdeBarMinWidthPctRight', 35)
let g:IdeBarStickyMode          = get(g:, 'IdeBarStickyMode', 3)
let g:IdeDebugVerbosity         = get(g:, 'IdeDebugVerbosity', 0)
let g:IdeTerminalPos            = get(g:, 'IdeTerminalPos', 'bottom')
let g:IdeAutoInit               = get(g:,'IdeAutoInit', 1)

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
"call ide#initCommands()
