let s:Bar = {}
let g:IdeBar = s:Bar

" Left, Bottom, Top, Right
let s:Flags = {}
let g:IdeBarFlags = s:Flags
let s:Flags.VERT = 1
let s:Flags.TOPLEFT = 2
let s:Flags.BOTRIGHT = 4
" vert | topleft
let s:Flags.LEFT = 3
" vert | botright
let s:Flags.RIGHT = 5
" botright
let s:Flags.BOTTOM = 4
" topleft
let s:Flags.TOP = 2

fun! s:setflags(...)
  let l:flags = 0
  for i in a:000
    let l:flags = or(l:flags, i)
  endfor
  return l:flags
endfun

fun! s:Bar.new(barid, layoutid)
  let l:obj = copy(self)
  let l:obj.winid = -1
  let l:obj.flags = 0
  let l:obj.width_pct = 0
  let l:obj.callbacks = {}
  let l:obj.widgets = {}
  let l:obj.id = a:barid
  let l:obj.state_ = 0
  let l:obj.layoutid = a:layoutid
  let l:obj.winheight = 0
  return l:obj
endfun

fun! s:Bar.setWinid(winid)
  let self.winid = a:winid
endfun

fun! s:Bar.getWinid()
  return win_getid(win_id2win(self.winid))
endfun

fun! s:Bar.setWidthPct(width_pct)
  let self.width_pct = a:width_pct
endfun

fun! s:Bar.addFlags(...)
  let self.flags = 0
  for i in a:000
    let self.flags = or(self.flags, i)
  endfor
  return self.flags
endfun

fun! s:Bar.setFlags(flags)
  let self.flags = a:flags
endfun

fun! s:Bar.open()
  if self.getWinid()
    return
  endif
  " create empty buffer
  let l:bufname = "idebar_" . self.layoutid . "_" . self.id
  let l:bufnr = bufnr(l:bufname)
  if l:bufnr == -1
    let l:bufnr = bufadd(l:bufname)
    call setbufvar(l:bufnr, "&buftype", "nofile")
    call setbufvar(l:bufnr, "&bufhidden", "hide")
    call setbufvar(l:bufnr, "&swapfile", 0)
    call setbufvar(l:bufnr, "&buflisted", 0)
    call setbufvar(l:bufnr, "&filetype", "idebuf")
  endif

  call ide#debugmsg('bar['.self.id.'].open BEGIN',
        \" layoutid " . self.layoutid .
        \" bufnr " . l:bufnr .
        \" winid " . self.getWinid())

  execute 'silent! sb' . l:bufnr
  call setbufvar(l:bufnr, "&number", 0)
  let l:winid = win_getid()
  call win_execute(l:winid, 'set winfixwidth')
  call win_execute(l:winid, 'set winfixheight')
  call self.setWinid(l:winid)
  
  call ide#debugmsg('bar['.self.id.'].open END',
        \" layoutid " . self.layoutid .
        \" bufnr " . l:bufnr .
        \" winid " . self.getWinid())
endfun

fun! s:Bar.close()
  call self.onCallback('close')
  call win_execute(self.winid, 'close!')
  let self.winid = -1
endfun

fun! s:Bar.toggle()
  if self.getWinid()
    call self.close()
    return
  endif
  call self.open()
endfun

fun! s:Bar.align()
  let l:winid = self.getWinid()
  if !l:winid | return | endif

  let l:flags = self.flags
  let l:aligntype = ''
  if and(l:flags, s:Flags.LEFT) == s:Flags.LEFT
    call win_execute(l:winid, 'wincmd H')
    let l:aligntype = 'LEFT'
    return

  elseif and(l:flags, s:Flags.RIGHT) == s:Flags.RIGHT
    call win_execute(l:winid, 'wincmd L')
    let l:aligntype = 'RIGHT'
    return

  elseif and(l:flags, s:Flags.BOTTOM) == s:Flags.BOTTOM
    call win_execute(l:winid, 'wincmd J')
    let l:aligntype = 'BOTTOM'
    return

  elseif and(l:flags, s:Flags.TOP) == s:Flags.TOP
    call win_execute(l:winid, 'wincmd K')
    let l:aligntype = 'TOP'
    return
  endif
  
  call ide#debugmsg('bar[' . self.id . '].align',
        \ ' aligning using ' .  l:aligntype)
endfun

fun! s:Bar.resize()
  let l:winid = self.getWinid()
  if !l:winid | return | endif

  let l:width = self.getMinWidth()
  if and(self.flags, s:Flags.VERT)
    call win_execute(l:winid, 'vert resize ' . l:width)
  else
    call win_execute(l:winid, 'resize ' . l:width)
  endif

  " The winheight value is lost when resizing buffers around
  " Saving this value will allow proper resizing of 
  " each widgets contained within each bar.
  let self.winheight = winheight(win_id2win(self.getWinid()))
  
  call ide#debugmsg('bar['.self.id.'].resize',
        \' width = ' . l:width . 
        \' winheight = ' . self.winheight)
endfun

fun! s:Bar.getMinWidth()
  return float2nr((self.width_pct / 100.00) * &columns)
endfun

fun! s:Bar.setCallback(type, callback)
  let self.callbacks[a:type] = a:callback
endfun

fun! s:Bar.onCallback(type)
  if has_key(self.callbacks, a:type)
    call self.callbacks[a:type]()
  endif
endfun

fun! s:Bar.addWidget(widget)
  let l:id = a:widget['id']
  let self.widgets[l:id] = a:widget
  call ide#debugmsg('bar[' . self.id . '].addWidgets',
        \" layoutid = " . self.layoutid .
        \" widget id =" . a:widget.id .
        \" widget layoutid = " . a:widget.layoutid .
        \" widget barid = " . a:widget.barid)
endfun

fun! s:Bar.getWidget(id)
  if has_key(self.widgets,a:id)
    return self.widgets[a:id]
  endif
  return 0
endfun

fun! s:Bar.getWidgets()
  return self.widgets
endfun

fun! s:Bar.openWidgets()
  call ide#debugmsg('bar[' . self.id . '].openWidgets',
        \'\n bar winid = ' . self.getWinid() .
        \'\n bar winnr = ' . win_id2win(self.getWinid()) .
        \'\n bar height = ' . winheight(win_id2win(self.winid))
        \)
  
  if len(keys(self.widgets)) == 0
    call ide#debugmsg('bar[' . self.id . '].openWidgets',
          \"no widgets to open, aborting")
    return
  endif
  
  " open each individual widgets
  for key in keys(self.widgets)
    call self.widgets[key].run_event('open', #{barid: self.id})
  endfor

  " resize window placeholder so all the widgets can be 
  " resized to fit correctly
  " this is done at the end because the previos operation
  " require 'room' to open the widgets first
  "call win_execute(self.getWinid(), 'resize 0') 
 

  " resize all widgets
  "call self.resizeWidgets()
endfun

fun! s:Bar.resizeWidgets()

  " nothing to do if there are no widgets, right?
  if len(keys(self.widgets)) == 0
    call ide#debugmsg('bar['. self.id . '].resizeWidgets',
          \"no widgets to resize, no work to do. Bye")
    return
  endif
 
  " if there is only one widget
  " it's wise not to resize the only space available to 1
  if len(keys(self.widgets)) > 1
    " some widgets take up all the space available
    " such as terminal window, so resizing it to 1
    " will actually resize the whole bar to 1
    call win_execute(self.getWinid(), 'resize 1') 
  endif
 
  " time to iterate each widgets and do the work
  for key in keys(self.widgets)
    " collect all the information needed to do proper resizing
    let l:bufnr = self.widgets[key].getvar('bufnr',-1)
    let l:h = self.widgets[key].getvar('minheightpct', 1)
    let l:resizeval = float2nr(l:h * self.winheight)
    
    let l:debug_str = 
          \ ' minheightpct = ' . l:h .
          \ ' bar winheight = ' . self.winheight .
          \ ' resizeval = ' . l:resizeval .
          \ ' bufnr = ' . l:bufnr .
          \ ' key = ' . key
    "call input(l:debug_str)
    call win_execute(bufwinid(l:bufnr),'resize ' . l:resizeval)

    call ide#debugmsg('bar['.self.id.'].resizeWidgets',
          \' resizing (' . key . ') to ' . l:resizeval)

    if has_key(self.widgets[key], 'opened')
      call self.widgets[key].opened()
    endif
  endfor
endfun

fun! s:Bar.closeWidgets()
  call ide#debugmsg('bar['. self.id . '].closeWidgets',
        \"closing widgets for bar " . self.id
        \." layoutid " . self.layoutid)
  for key in keys(self.widgets)
    call ide#debugmsg('bar['. self.id . '].closeWidgets',
      \ 'closing widget ' . key)
    call self.widgets[key].run_event('close', #{barid: self.id})
  endfor
endfun
