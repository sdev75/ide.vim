let s:Widget = {}
let g:IdeWidget = s:Widget

let s:Flags = {}
let g:WidgetFlags = s:Flags
let s:Flags.DUMMY = 1

let s:Events = #{
      \constructor:1,
      \destructor:1,
      \open:1,
      \close:1,
      \update:1
      \}
let s:PublicEvents = #{
      \open:1,
      \close:1,
      \update:1
      \}
let s:widgets = {}

fun! s:Widget.register(widget)
  let s:widgets[a:widget.id] = a:widget
endfun

fun! s:Widget.get(widgetid)
  return get(s:widgets, a:widgetid, {})
endfun

fun! s:Widget.new(id)
  let l:obj = copy(self)
  let l:obj.id = a:id
  let l:obj.type = s:Flags.DUMMY
  let l:obj.constructed = 0
  let l:obj.vars = #{open:0}
  return l:obj
endfun

fun! s:Widget.run_event_(event_name, payload)
  " execute parent callback
  let l:res = self[a:event_name.'_'](a:payload)
  "execute "let l:res = self['" . a:event_name . "_']()"
  if l:res == -1
    " stop propagation if return value is -1
    call ide#debugmsg("widget.run_event_", "Stopping propagation for " . a:event_name)
    return
  endif
  " execute any callbacks
  if !has_key(self, a:event_name)
    return
  endif
  return self[a:event_name](self, a:payload)
endfun

fun! s:Widget.run_event(event_name, payload)
  call ide#debugmsg("widget.run_event", "widgetid " . self.id . " event " . a:event_name)
  if !has_key(s:PublicEvents, a:event_name)
    echoerr '[Widget] run_event(): Invalid event: ' . a:event_name
    return
  endif
  if !self.constructed
    call ide#debugmsg("widget.run_event", "widget requires construction")
    let l:res = self.run_event_('constructor', a:payload)
    if l:res == -1
      echoerr "[Widget] run_event_(): Failed to construct widget " . self.id
      return -1
    endif
  endif
  return self.run_event_(a:event_name, a:payload)
endfun

fun! s:Widget.constructor_(payload)
  call ide#debugmsg("widget.constructor_", "invoked")
  if self.constructed
    echoerr "[Widget] Already constructed. ABORTING"
    return -1
  endif
  let self.constructed = 1
endfun

fun! s:Widget.destructor_(payload)
  call ide#debugmsg("widget.destructor_", "invoked")
  if !self.constructed
    echoerr "[Widget] Already destructed. ABORTING"
    return -1
  endif
  let self.constructed = 0
endfun

fun! s:Widget.open_(payload)
  call self.setvar('open', 1)
endfun

fun! s:Widget.close_(payload)
  call self.setvar('open', 0)
endfun

fun! s:Widget.update_(payload)
endfun

fun! s:Widget.setvar(key, val)
  let self.vars[a:key] = a:val
endfun

fun! s:Widget.getvar(key, default)
  return get(self.vars, a:key, a:default)
endfun
