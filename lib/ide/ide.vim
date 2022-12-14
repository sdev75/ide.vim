let s:Ide = #{
      \ shutdown: { -> -1 },
      \ redraw: { -> -1 },
      \ getLayout: { -> -1 },
      \ log: { -> -1 },
      \ logmsg: { -> -1 },
      \ debug: { -> -1 },
      \ layouts: {},
      \ callbacks: {},
      \ }
let g:Ide = s:Ide

let s:Ide.pluginpath = expand('<sfile>:p:h:h:h')

fun! s:init(autoDraw = 1)
  call g:Ide.debug(3, "init",
        \ "Initializing Ide object")
  " Self modify the IDE global object to use concrete implementation
  let l:sid = expand('<SID>')
  let g:Ide.getLayout = function(l:sid .. 'getLayout')
  let g:Ide.redraw = function(l:sid .. 'redraw')
  " Clearing the init to avoid subsequent calls to it
  let g:Ide.init = { -> -1 }

  " Binding shutdown
  let g:Ide.shutdown = function(l:sid .. 'shutdown')

  call s:setAutoDraw(a:autoDraw)
endfun

fun! s:setAutoDraw(enable)
  if a:enable == 1
    call g:Ide.debug(3, "setAutoDraw","Enabling IdeAutoDraw")
    " Linking 'User' events together
    augroup IdeLibAutoDraw
      au User OnIdeResize    call g:Ide.redraw()
    augroup END
    " Fire User Ide resize event (redraws the layout)
    do User OnIdeResize
    return
  endif

  call g:Ide.debug(3, "setAutoDraw","Disabling IdeAutoDraw")
  " Remove autocommands
  augroup IdeLibAutoDraw
    au!
  augroup END
  return
endfun

fun! s:shutdown()
  call g:Ide.debug(3, "shutdown", 
        \ "Shutting down IDE")
  let payload = {'event': 'shutdown'}
  call s:Ide.runCallback("shutdown", l:payload)
endfun

" Get instance of a layout
" When no argument, it is returned the layout by tabpagenr
fun! s:getLayout(...)
  if !len(a:000) || a:1 == 1
    let l:layoutid = tabpagenr()
  else
    let l:layoutid = a:1
  endif
  return g:IdeLayouts.get(l:layoutid)
endfun

" Redraw current layout
fun! s:redraw()
  let l:layout = g:Ide.getLayout()
  let l:alignment = l:layout.getConfig().panelAlignment
  return g:IdeLayouts.draw(l:alignment)
endfun

fun! s:Ide.init()
  call <SID>init(1)
endfun

" Assign a logger instance to the Ide object
" A level will be assigned if the level arg is not -1
" This allows call to setLogger without altering the internal properties
" which might have been previously initialized before injection
fun! s:Ide.setLogger(logger, level = -1)
  if a:level != -1
    call a:logger.setVerbosityLevel(a:level)
  endif

  let self.logger = a:logger
  
  " Using partials to avoid code repetition
  let g:Ide.log = function(funcref('g:Ide.logger.log'), g:Ide.logger)
  let g:Ide.debug = function(funcref('g:Ide.logger.log'), ['debug'], g:Ide.logger)
  let g:Ide.logmsg = function(funcref('g:Ide.logger.log'), ["debug",1,""], g:Ide)
endfun

"fun! s:Ide.getRootpath()
"  return self.rootpath_
"endfunction
"
"fun! s:Ide.setRootpath(...)
"  let l:abspath = get(a:, 1, expand("%:p:h"))
"  let self.rootpath_ = l:abspath
"endfun

"fun! s:Ide.toggleBar(pos)
"  let l:layout = self.getLayout()
"  call l:layout['toggleBar'](a:pos)
"  " return to previous winid
"  call win_gotoid(l:layout.getvar('originWinid', -1))
"endfun
"
"fun! s:Ide.toggleTerminal()
"  let l:layout = self.getLayout()
"  call l:layout['toggleTerminal'](g:IdeTerminalPos)
"  let l:bar = l:layout.getBar(l:layout.getBarId(g:IdeTerminalPos))
"  call win_gotoid(l:bar.getWinid())
"endfun
"
"fun! s:Ide.openTerminalAndFocus()
"  let l:layout = self.getLayout()
"  let l:barid = l:layout.getBarId(g:IdeTerminalPos)
"  let l:bar = l:layout.getBar(l:barid)
"  call l:layout.openBar(l:barid)
"  call win_gotoid(l:bar.getWinid())
"endfun

" Assign a callback to list of callbacks
fun! s:Ide.setCallback(name, callback)
  let self.callbacks[a:name] = a:callback
endfun

" Execute callback by name
fun! s:Ide.runCallback(name, payload)
  if has_key(self.callbacks, a:name)
    call g:Ide.debug(3, "Ide.invokeCallback",
          \ "Callback fired: " .. a:name
          \ .. " payload: " .. string(a:payload))
    call self.callbacks[a:name](a:payload)
  endif
endfun

augroup IdeLib
  au!
  au User OnIdeInit      call s:init(g:IdeAutoDraw)
  au User OnIdeShutdown  call g:Ide.shutdown()
augroup END
