let s:Ide = {}
let g:Ide = s:Ide

let s:Ide.pluginpath = expand('<sfile>:p:h:h:h')
let s:Ide.layouts = {}
let s:Ide.widgets = {}

function! s:Ide.getRootpath()
  return self.rootpath_
endfunction

function! s:Ide.setRootpath(...)
  let l:abspath = get(a:, 1, expand("%:p:h"))
  let self.rootpath_ = l:abspath
endfunction

fun! s:Ide.initLayout_(id)
  let l:layout = g:IdeLayout.new()
  let l:layout.id = a:id
  let self.layouts[a:id] = l:layout
  return l:layout
endfun

fun! s:Ide.getLayout(...)
  if !len(a:000)
    let l:id = tabpagenr()
  else
    let l:id = a:0
  endif
  if !has_key(self.layouts, l:id)
    return self.initLayout_(l:id)
  endif
  return self.layouts[l:id]
endfun

fun! s:Ide.toggleBar(pos)
  let l:layout = self.getLayout()
  call l:layout['toggleBar'](a:pos)
endfun

fun! s:Ide.registerWidget(widget)
  let self.widgets[a:widget.id] = a:widget
endfun

fun! s:Ide.getWidget(id)
  return get(self.widgets, a:id, {})
endfun
