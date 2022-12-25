let s:Widget = {}
let g:IdeWidget = s:Widget

" Reserved for future use
let s:Flags = {}
let g:WidgetFlags = s:Flags
let s:Flags.DUMMY = 1

" List of public and private scoped events
let s:Events = #{
      \constructor:1,
      \destructor:1,
      \open:1,
      \close:1,
      \update:1
      \}
" List of events with public scope
let s:PublicEvents = #{
      \open:1,
      \close:1,
      \update:1
      \}

fun! s:Widget.new(id)
  let l:obj = copy(self)
  let l:obj.id = a:id
  let l:obj.type = s:Flags.DUMMY
  let l:obj.constructed = 0
  let l:obj.vars = #{open:0}
  return l:obj
endfun

"fun! s:Widget.run_event_(event_name, payload)
"  call g:Ide.debug(3, "Widget.run_event_",
"        \ "event_name " . a:event_name)
"
"  let l:funcname = a:event_name . "_"
"  
"  " Execute parent callback if it exists
"  if has_key(self, l:funcname)
"    call g:Ide.debug(3, "Widget.run_event_",
"          \ "Executing parent callback for " . l:funcname)
"    " execute parent callback (ending in underscore)
"    let l:res = self[l:funcname](a:payload)
"    if l:res == -1
"      " stop propagation if return value is -1
"      call g:Ide.debug(3, "Widget.run_event_",
"            \ "Stopping propagation for '" . a:event_name . "'")
"      return
"    endif
"  endif
"  
"  " Execute the actual callback if it exists
"  if !has_key(self, a:event_name)
"    call g:Ide.debug(5, "Widget.run_event",
"          \ "Missing callback for '" . a:event_name . "'")
"    return
"  endif
"  return self[a:event_name](self, a:payload)
"endfun
"
"fun! s:Widget.run_event(event_name, payload)
"  call g:Ide.debug(3, 'Widget.run_event', 
"        \ "Event '" .  a:event_name . "'" . 
"        \ " called for " . self.id)
" 
"  " Ensure the event name is a valid one
"  "if !has_key(s:PublicEvents, a:event_name)
"  "  echoerr 'Invalid event: ' . a:event_name
"  "  return
"  "endif
"
"  " Lazy construct widgets if they aren't already
"  if !self.constructed
"    call g:Ide.debug(3, "Widget.run_event", 
"          \ "Constructor required " . self.id)
"    let l:res = self.run_event_('constructor', a:payload)
"    if l:res == -1
"      echoerr "Failed to construct widget " . self.id
"      return -1
"    endif
"  endif
"  
"  return self.run_event_(a:event_name, a:payload)
"endfun
"
fun! s:Widget.constructor_(payload)
  call g:Ide.debug(3, "Widget.constructor_",
        \ " Constructor_ called for " . self.id)
 
  " Check if widget has already been constructed
  if self.constructed
    echoerr "Constructor called twice. OH MY"
    return -1
  endif

  " Flag widget as constructed
  let self.constructed = 1
endfun

fun! s:Widget.destructor_(payload)
  call g:Ide.debug(3, "Widget.destructor_",
        \ "Destructor invoked for " . self.id)
 
  " Run the destructor only once
  if !self.constructed
    echoerr "Duplicate call or never constructed before. OOPS"
    return -1
  endif

  " Flag widget accordingly
  let self.constructed = 0
endfun

"fun! s:Widget.open_(payload)
"  call ide#debug(3, "Widget",
"        \ "Widget.open_() " . self.id)
"  call g:IdeWidgets.setvar(self, "open", 1)
"endfun
"
"fun! s:Widget.close_(payload)
"  call ide#debug(3, "Widget",
"        \ "Widget.close_() " . self.id)
"  call g:IdeWidgets.setvar(self, "open", 0)
"endfun
"
"fun! s:Widget.setHeightPct(winid, pct)
"  call win_execute(a:winid,
"        \ 'resize ' . float2nr(a:pct * &lines))
"endfun
