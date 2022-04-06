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
  let l:layout = self.getLayout()
  call l:layout['toggleBar'](a:pos)
endfun

fun! s:Ide.registerWidget(widget)
  let self.widgets_[a:widget.id] = a:widget
endfun

fun! s:Ide.addWidget(layoutid, position, widgetid)
  let l:widget = self.getRegisteredWidget(a:widgetid)
  if empty(l:widget)
    echoerr "Widget was not registered: " . a:widgetid
    return
  endif
  let l:payload = {}
  let l:payload.layoutid = a:layoutid
  let l:payload.position = a:position
  let l:payload.widgetid = l:widget.id
  let self.widgets[l:widget.id] = l:payload
endfun

fun! s:Ide.getRegisteredWidget(id)
  return get(self.widgets_, a:id, {})
endfun

fun! s:Ide.getWidgets()
  return self.widgets
endfun
