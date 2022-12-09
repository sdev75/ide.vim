let s:Ide = {}
let g:Ide = s:Ide

let s:Ide.pluginpath = expand('<sfile>:p:h:h:h')
let s:Ide.layouts = {}

function! s:Ide.getRootpath()
  return self.rootpath_
endfunction

function! s:Ide.setRootpath(...)
  let l:abspath = get(a:, 1, expand("%:p:h"))
  let self.rootpath_ = l:abspath
endfunction

" Get instance of a layout
" When no argument, it is returned the layout by tabpagenr
fun! s:Ide.getLayout(...)
  if !len(a:000) || a:1 == 1
    let l:layoutid = tabpagenr()
  else
    let l:layoutid = a:1
  endif
  return g:IdeLayouts.get(l:layoutid)
endfun

" Redraw current layout
fun! s:Ide.redraw()
  return self.getLayout().draw()
endfun

fun! s:Ide.toggleBar(pos)
  let l:layout = self.getLayout()
  call l:layout['toggleBar'](a:pos)
  " return to previous winid
  call win_gotoid(l:layout.getvar('originWinid', -1))
endfun

fun! s:Ide.toggleTerminal()
  let l:layout = self.getLayout()
  call l:layout['toggleTerminal'](g:IdeTerminalPos)
  let l:bar = l:layout.getBar(l:layout.getBarId(g:IdeTerminalPos))
  call win_gotoid(l:bar.getWinid())
endfun

fun! s:Ide.openTerminalAndFocus()
  let l:layout = self.getLayout()
  let l:barid = l:layout.getBarId(g:IdeTerminalPos)
  let l:bar = l:layout.getBar(l:barid)
  call l:layout.openBar(l:barid)
  call win_gotoid(l:bar.getWinid())
endfun

fun! s:Ide.init_()
  return self.getLayout().draw()
endfun

fun! s:Ide.log(type, level, prefix, data)
  if a:type ==? "info"
    return self.logger.info(a:level, a:prefix, a:data)
  elseif a:type ==? "warn"
    return self.logger.warn(a:level, a:prefix, a:data)
  elseif a:type ==? "error"
    return self.logger.error(a:level, a:prefix, a:data)
  elseif a:type ==? "debug"
    return self.debug(a:level, a:prefix, a:data)
  endif
endfun

fun! s:Ide.debug(level, prefix, msg)
  return self.logger.debug(a:level, a:prefix, a:msg)
endfun

fun! s:Ide.logmsg(msg)
  return self.logger.debug(1, "", a:msg)
endfun

fun! s:Ide.setLogger(logger)
  let self.logger = a:logger
endfun

fun! s:Ide.shutdown_()
endfun

augroup IdeLib
  autocmd!
  autocmd User OnIdeInit      call s:Ide.init_()
  autocmd User OnIdeShutdown  call s:Ide.shutdown_()
  autocmd User OnIdeResize    call s:Ide.getLayout().redraw()
augroup END
