let s:Ide = {}
let g:Ide = s:Ide

let s:Ide.pluginpath = expand('<sfile>:p:h:h:h')
let s:Ide.layouts = {}
let s:Ide.widgets = {}
let s:Ide.widgets_ = {}

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
  if !len(a:000)
    let l:layoutid = tabpagenr()
  else
    let l:layoutid = a:1
  endif
  if !has_key(self.layouts, l:layoutid)
    return self.initLayout_(l:layoutid)
  endif
  return self.layouts[l:layoutid]
endfun

fun! s:Ide.toggleBar(pos)
  " save current winid
  let l:layout = self.getLayout()
  " save current winid and bufnr
  "let l:layout.mainWinid = win_getid()
  "let l:layout.mainBufnr = bufnr('')
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

fun! s:Ide.addWidget(layoutid, position, widgetid)
  let l:widget = g:IdeWidget.get(a:widgetid)
  if empty(l:widget)
    echoerr "Widget was not registered: " . a:widgetid
    return
  endif
  let l:payload = {}
  let l:payload.layoutid = a:layoutid
  let l:payload.position = a:position
  let l:payload.widgetid = l:widget.id
  if !has_key(self.widgets, l:widget.id)
    let self.widgets[l:widget.id] = []
  endif
  call add(self.widgets[l:widget.id], payload)
  "let self.widgets[l:widget.id] = l:payload
endfun

fun! s:Ide.getWidgets()
  return self.widgets
endfun

fun! s:Ide.getWidget(widgetid)
  return get(self.widgets, a:widgetid, -1)
endfun

fun! s:Ide.shutdown_()
  call self.shutdownWidgets_()
endfun

fun! s:Ide.shutdownWidgets_()
  " iterate through every existing layout
  for layoutid in keys(self.layouts)
    call ide#debugmsg("ide.shutdown_", "cleaning up layoutid " . layoutid)
    
    " iterate through every layout's bar
    for bar in self.layouts[layoutid].getBars()
      call ide#debugmsg("ide.shutdown_", "cleaning up all widgets for bar " . bar.id)
    
      " iterate through every bar's widget
      let widgets = bar.getWidgets()
      for widgetid in keys(widgets)
        let l:widget = widgets[widgetid]
        
        if empty(widget) | continue | endif
        call ide#debugmsg("ide.shutdown_", "destructing widget " . widget.id)
        call widget.run_event_('destructor', {})
      endfor
    endfor
  endfor

  "let x = inputlist([])
endfun

augroup IdeLib
  autocmd!
  autocmd User OnShutdown call s:Ide.shutdown_() 
augroup END
