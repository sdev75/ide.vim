let s:Widget = {}
let g:IdeWidget = s:Widget

let s:Flags = {}
let g:WidgetFlags = s:Flags
let s:Flags.DUMMY = 1

fun! s:Widget.new(id)
  let l:obj = copy(self)
  let l:obj.id = a:id
  let l:obj.type = s:Flags.DUMMY
  let l:obj.callbacks = {}
  return l:obj
endfun

fun! s:Widget.addCallback(name, cb)
  let self.callbacks[a:name] = a:cb
endfun

fun! s:Widget.open()
  if has_key(self.callbacks, 'open')
    call self.callbacks['open'](self)
  endif
endfun

fun! s:Widget.update()
  if has_key(self.callback, 'update')
    call self.callback['update'](self)
  endif
endfun

fun! s:Widget.close()
  if has_key(self.callbacks, 'close')
    call self.callbacks['close'](self)
  endif
endfun

fun! s:Widget.getbufnr()
  return bufnr(get(self, 'bufnr', -1))
endfun
