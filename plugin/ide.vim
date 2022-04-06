" ==
" Description: basic rudimentary helper to handle ide functionality
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
let g:IdeBarStickyMode = get(g:, 'IdeBarStickyMode', 0)
" left, bottom, top, right
let g:IdeBarMinWidthPct = get(g:, 'IdeBarMinWidthPct', 
      \ [15, 10, 10, 35])
let g:IdeBarMinWidthPctLeft     = get(g:, 'IdeBarMinWidthPctLeft', 15)
let g:IdeBarMinWidthPctBottom   = get(g:, 'IdeBarMinWidthPctBottom', 10)
let g:IdeBarMinWidthPctTop      = get(g:, 'IdeBarMinWidthPctTop', 10)
let g:IdeBarMinWidthPctRight    = get(g:, 'IdeBarMinWidthPctRight', 35)
let g:IdeTerminalBar = get(g:, 'IdeTerminalBar', 'bottom')
"autocmd ExitPre * doautocmd User OnVimExitPre

augroup Ide
  autocmd!
  autocmd VimResized * doautocmd User OnVimResized
  autocmd VimLeavePre * doautocmd User OnShutdown
  autocmd FileType c,cpp,h call ide#loadlib('ide/c')
augroup END

call ide#init()
call ide#initCommands()
