let s:Widget = {}
let g:IdeWidget = s:Widget

let s:Flags = {}
let g:WidgetFlags = s:Flags
let s:Flags.DUMMY = 1

let s:Events = #{construct:1,destruct:1,open:1,close:1}
let s:PublicEvents = #{open:1,close:1}

fun! s:Widget.new(id)
  let l:obj = copy(self)
  let l:obj.id = a:id
  let l:obj.type = s:Flags.DUMMY
  let l:obj.constructed = 0
  let l:obj.vars = #{open:0}
  return l:obj
endfun

fun! s:Widget.run_event_(event_name)
  " execute parent callback
  execute "let l:res = self['" . a:event_name . "_']()"
  if l:res == -1
    " stop propagation if return value is -1
    return
  endif
  " execute any callbacks
  if !has_key(self, a:event_name)
    return
  endif
  return self[a:event_name](self)
endfun

fun! s:Widget.run_event(event_name)
  if !has_key(s:PublicEvents, a:event_name)
    echoerr 'Invalid event: ' . a:event_name
    return
  endif
  if !self.constructed
    let l:res = self.run_event_('construct')
    if l:res == -1
      echoerr "Failed to construct widget " . self.id
      return -1
    endif
  endif
  return self.run_event_(a:event_name)
endfun

fun! s:Widget.construct_()
  echom "parent construct() called"
  let self.constructed = 1
endfun

fun! s:Widget.destruct_()
  echom "parent destruct() called"
  let self.constructed = 0
  "if has_key(self.callbacks, 'destruct')
  "  call self.callback['destruct'](self)
  "endif
endfun

fun! s:Widget.open_()
  echom "parent open() called"
  call self.setvar('open', 1)
endfun

fun! s:Widget.close_()
  echom "parent close() called"
  call self.setvar('open', 0)
endfun

fun! s:Widget.getbufnr()
  return bufnr(self.getvar('bufvar', -1))
  "return winbufnr(get(self, 'winid', -1))
  "return bufnr(get(self, 'bufnr', -1))
endfun

fun! s:Widget.setbufnr(bufnr)
  "let self.bufnr = a:bufnr
endfun

fun! s:Widget.setWinid(winid)
  let self.winid = a:winid
endfun

fun! s:Widget.setvar(key, val)
  let self.vars[a:key] = a:val
endfun

fun! s:Widget.getvar(key, default)
  return get(self.vars, a:key, a:default)
endfun
