let s:Widgets = {}
let g:IdeWidgets = s:Widgets

" Unique list of widgets and their procedures and metadata
let s:widgets = {}

" List of multiple widgets added
" Widgets are sorted by widgetId
" Each widget may have multiple instances
let s:instances = []

fun! s:Widgets.register(widget)
  call g:Ide.debug(3, "Widget.register",
        \ "Registering widget " .. a:widget.id)
  let s:widgets[a:widget.id] = a:widget
endfun

fun! s:Widgets.get_(widgetid)
  return get(s:widgets, a:widgetid, {})
endfun

fun! s:Widgets.get(widgetid)
  let l:widget = self.get_(a:widgetid)
  if empty(l:widget)
    call g:Ide.debug(3, "Widgets.get",
          \ "Widget not registered: " .. a:widgetid)
    return {}
  endif
 
  return l:widget
endfun
"
fun! s:Widgets.getInstances()
  return s:instances
endfun

fun! s:Widgets.run_event_(widget, event_name, payload)
  call g:Ide.debug(3, "Widgets.run_event_",
        \ "widgetid " .. a:widget.id ..
        \ " event " .. a:event_name ..
        \ " payload " .. string(a:payload))

  let l:funcname = a:event_name . "_"
  
  " Execute parent callback if it exists
  if has_key(a:widget, l:funcname)
    call g:Ide.debug(3, "Widgets.run_event_",
          \ "Executing parent function " . l:funcname)
    " execute parent callback (ending in underscore)
    let l:res = a:widget[l:funcname](a:payload)
    if l:res == -1
      " stop propagation if return value is -1
      call g:Ide.debug(3, "Widgets.run_event_",
            \ "Stopping propagation for '" . a:event_name . "'")
      return
    endif
  endif
  
  " Execute the actual callback if it exists
  if !has_key(a:widget, a:event_name)
    call g:Ide.debug(3, "Widgets.run_event",
          \ "Callback function not found for event "
          \ .. a:event_name)
    return
  endif
  return a:widget[a:event_name](a:widget, a:payload)
endfun

fun! s:Widgets.run_event(widget, event_name, payload)
  call g:Ide.debug(3, 'Widgets.run_event',
        \ "widgetid " .. a:widget.id ..
        \ " event " .. a:event_name ..
        \ " payload " .. string(a:payload))
 
  " Ensure the event name is a valid one
  "if !has_key(s:PublicEvents, a:event_name)
  "  echoerr 'Invalid event: ' . a:event_name
  "  return
  "endif

  " Lazy construct widgets
  if !a:widget.constructed
    let l:res = self.run_event_(a:widget, 'constructor', a:payload)
    if l:res == -1
      call g:Ide.debug(3, "Widgets.run_event",
            \ "Widget constructor returned -1"
            \ .. " widgetid: " .. a:widget.id)
      return -1
    endif
  endif
  
  "return self.run_event_(a:widget, a:event_name, a:payload)
endfun
"
"fun! s:Widgets.getInstancesByLayout(instances, layoutid)
"  return filter(copy(a:instances),
"        \ "v:val.layoutid == " a:layoutid) 
"endfun
"
"fun! s:Widgets.getInstancesByBarId(instances, barid)
"  " Widgets having layoutid -1 must be filtered out
"  " They are placeholders used to instantiate objects
"  return filter(copy(a:instances),
"        \ "v:val.layoutid != -1" .
"        \ "&& v:val.barid == '" . a:barid . "'")
"endfun
"
"fun! s:Widgets.getInstancesById(instances, widgetid)
"  " Widgets having layoutid -1 must be filtered out
"  " They are placeholders used to instantiate objects
"  return filter(copy(a:instances),
"        \ "v:val.layoutid != -1" .
"        \ "&& v:val.widgetid ==# '" . a:widgetid . "'")
"endfun
"
"" TODO might need some refactoring
"fun! s:Widgets.runEvent(widgetid, event_name, payload)
"  call ide#debug(3, "Widgets.runEvent",
"        \ "widgetid " . a:widgetid .
"        \ " event_name " . a:event_name)
"  let l:instances = self.getInstancesById(
"        \ self.getInstances(), a:widgetid)
"  for instance in l:instances
"    call ide#debug(4, "Widgets.runEvent",
"          \ "Calling run_event on widget instance" .
"          \ " layoutid " . instance.layoutid .
"          \ " barid " . instance.barid)
"    call instance.widget.run_event(a:event_name, a:payload)
"  endfor
"endfun
"
"fun! s:Widgets.addInstance(layoutid, barid, widgetid)
"  " Ensure the widget has been properly registered first
"  let l:widget = self.get(a:widgetid)
"  if empty(l:widget) | return -1 | endif
"
"  " Build payload with metadata
"  " A widget may be added to multiple bars one or more times
"  let l:payload = #{
"        \ layoutid:   a:layoutid,
"        \ barid:      a:barid,
"        \ widgetid:   a:widgetid,
"        \ widget:     {}
"        \ }
"  " Store instance to our list
"  " Each instance can be filtered out using filter()
"  " This allows sort filter by layoutid, barid and so on.
"  call self.addInstance_(l:payload)
"endfun
"
"fun! s:Widgets.addInstance_(instance)
"  call ide#debug(5, "Widgets.addInstance_",
"        \ "Adding instance for widgetid " . a:instance.widgetid)
"  call add(s:instances, a:instance)
"endfun
"
"fun! s:Widgets.printInstances()
"  echom "There are " . len(self.getInstances()) . " widgets"
"  echom printf("%-10s %-6s %-10s %-10s",
"        \ "LayoutID", "BarID", "Position", "WidgetID")
"  echom printf("%40s", repeat("-",10 + 6+ 10 + 10 + 4))
"  for widget in self.getInstances()
"    echom printf("%-10d %-6d %-10s %-10s", 
"          \ widget.layoutid,
"          \ widget.barid,
"          \ g:IdeLayout.getBarPosition(widget.barid),
"          \ widget.widgetid)
"  endfor 
"endfun
"
"fun! s:Widgets.setvar(widget, key, val)
"  let a:widget.vars[a:key] = a:val
"endfun
"
"fun! s:Widgets.getvar(widget, key, default)
"  return get(a:widget.vars, a:key, a:default)
"endfun
"
"fun! s:Widgets.resizeWidget(winid, pct)
"  call win_execute(a:winid,
"        \ 'resize ' . float2nr(a:pct * &lines))
"endfun
"
"fun! s:Widgets.newBlankBuffer(bufname)
"  execute 'silent! new'
"  let l:bufnr = bufnr('$')
"  call setbufvar(l:bufnr, "&buflisted", 0)
"  call setbufvar(l:bufnr, '&number', 0)
"  call setbufvar(l:bufnr, '&list', 0)
"  execute 'silent! file ' . a:bufname
"
"  call win_execute(bufwinid(l:bufnr), 'close!')
"  return l:bufnr
"endfun
"
"fun! s:Widgets.getWidgetBar(widget)
"  let l:layout  = g:Ide.getLayout(a:widget.layoutid)
"  let l:bar     = l:layout.getBar(a:widget.barid)
"  return l:bar
"endfun
