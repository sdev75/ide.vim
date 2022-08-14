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

fun! s:Ide.initLayout_(layoutid)
  let l:layout = g:IdeLayout.new(a:layoutid)
  let self.layouts[a:layoutid] = l:layout
  return self.layouts[a:layoutid]
endfun

fun! s:Ide.getLayout(...)
  if !len(a:000) || a:1 == -1
    let l:layoutid = tabpagenr()
  else
    let l:layoutid = a:1
  endif
 
  call ide#debug(5, "Ide.getLayout",
        \ "getLayout() called. Layoutid " . l:layoutid)

  if !has_key(self.layouts, l:layoutid)
    return self.initLayout_(l:layoutid)
  endif
  return self.layouts[l:layoutid]
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
  call self.getLayout()
endfun

fun! s:Ide.shutdown_()
endfun

augroup IdeLib
  autocmd!
  autocmd User OnIdeInit      call s:Ide.init_()
  autocmd User OnIdeShutdown  call s:Ide.shutdown_()
  autocmd User OnIdeResize    call s:Ide.getLayout().resizeBars()
augroup END
