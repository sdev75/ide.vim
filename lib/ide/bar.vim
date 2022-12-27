let s:Bar = {}
let g:IdeBar = s:Bar

" Left, Bottom, Top, Right
"let s:Flags = {}
"let g:IdeBarFlags = s:Flags
"let s:Flags.VERT = 1
"let s:Flags.TOPLEFT = 2
"let s:Flags.BOTRIGHT = 4
"" vert | topleft
"let s:Flags.LEFT = 3
"" vert | botright
"let s:Flags.RIGHT = 5
"" botright
"let s:Flags.BOTTOM = 4
"" topleft
"let s:Flags.TOP = 2
"
"fun! s:setflags(...)
"  let l:flags = 0
"  for i in a:000
"    let l:flags = or(l:flags, i)
"  endfor
"  return l:flags
"endfun
"
"fun! s:Bar.new(barid, layoutid)
"  let l:obj = copy(self)
"  let l:obj.winid = -1
"  let l:obj.flags = 0
"  let l:obj.width_pct = 0
"  let l:obj.callbacks = {}
"  let l:obj.widgets = {}
"  let l:obj.id = a:barid
"  let l:obj.state_ = 0
"  let l:obj.layoutid = a:layoutid
"  let l:obj.winheight = 0
"  let l:obj.vars_ = {}
"  return l:obj
"endfun
"
"fun! s:Bar.setWinid(winid)
"  let self.winid = a:winid
"endfun
"
"fun! s:Bar.getWinid()
"  return win_getid(win_id2win(self.winid))
"endfun
"
"fun! s:Bar.setWidthPct(width_pct)
"  let self.width_pct = a:width_pct
"endfun
"
"fun! s:Bar.addFlags(...)
"  let self.flags = 0
"  for i in a:000
"    let self.flags = or(self.flags, i)
"  endfor
"  return self.flags
"endfun
"
"fun! s:Bar.setFlags(flags)
"  let self.flags = a:flags
"endfun
"
"fun! s:Bar.open()
"  call ide#debug(3, "Bar.open",
"        \ "Open called for bar " . self.id .
"        \ " winid " . self.getWinid())
"
"  if self.getWinid() | return | endif
"  
"  " create empty buffer unique to every bar
"  " format: idebar_{layoutid}_{barid}
"  let l:bufname = "idebar_" . self.layoutid . "_" . self.id
"  let l:bufnr = bufnr(l:bufname)
"  if l:bufnr == -1
"    let l:bufnr = bufadd(l:bufname)
"    call setbufvar(l:bufnr, "&buftype", "nofile")
"    call setbufvar(l:bufnr, "&bufhidden", "hide")
"    call setbufvar(l:bufnr, "&swapfile", 0)
"    call setbufvar(l:bufnr, "&buflisted", 0)
"    call setbufvar(l:bufnr, "&filetype", "idebar")
"    call setbufvar(l:bufnr, "&number", 0)
"    
"    call ide#debug(3, "Bar.open",
"          \ "new buffer created " . l:bufname .
"          \ " bufnr " . l:bufnr)
"  endif
"
"  " Silently switch to bar buffer
"  execute 'silent! sb' . l:bufnr
"  
"  " Set bar window fixed dimensions
"  let l:winid = win_getid()
"  call win_execute(l:winid, 'set winfixwidth')
"  call win_execute(l:winid, 'set winfixheight')
"
"  " Store the winid for future use
"  call self.setWinid(l:winid)
" 
"  call ide#debug(3, "Bar.open",
"        \ "opened bar " . self.id .
"        \ " bufnr " . l:bufnr .
"        \ " winid " . l:winid)
"endfun
"
"fun! s:Bar.close()
"  call ide#debug(3, "Bar.close",
"        \ "Close for bar " . self.id)
"  call win_execute(self.winid, 'close!')
"  call self.setWinid(-1)
"  call self.setvar('hidden',0)
"endfun
"
"fun! s:Bar.toggle()
"  call ide#debug(3, "Bar.toggle",
"        \ "Toggle called for bar " . self.id)
"  if self.getWinid()
"    call self.close()
"    return
"  endif
"  call self.open()
"endfun
"
"fun! s:Bar.align()
"  call ide#debug(3, "Bar.align",
"        \ "Align called for bar " . self.id)
"  
"  let l:winid = self.getWinid()
"  if !l:winid | return | endif
"
"  let l:flags = self.flags
"  let l:aligntype = ''
"  if and(l:flags, s:Flags.LEFT) == s:Flags.LEFT
"    call win_execute(l:winid, 'wincmd H')
"    let l:aligntype = 'LEFT'
"    return
"
"  elseif and(l:flags, s:Flags.RIGHT) == s:Flags.RIGHT
"    call win_execute(l:winid, 'wincmd L')
"    let l:aligntype = 'RIGHT'
"    return
"
"  elseif and(l:flags, s:Flags.BOTTOM) == s:Flags.BOTTOM
"    call win_execute(l:winid, 'wincmd J')
"    let l:aligntype = 'BOTTOM'
"    return
"
"  elseif and(l:flags, s:Flags.TOP) == s:Flags.TOP
"    call win_execute(l:winid, 'wincmd K')
"    let l:aligntype = 'TOP'
"    return
"  endif
" 
"  call ide#debug(3, "Bar.align",
"        \ "Bar aligned to " . l:aligntype)
"endfun
"
"fun! s:Bar.resize()
"  call ide#debug(3, "Bar.resize",
"        \ "Resize called for bar " . self.id)
"
"  let l:winid = self.getWinid()
"  if !l:winid | return | endif
"
"  let l:width = self.getMinWidth()
"  if and(self.flags, s:Flags.VERT)
"    call win_execute(l:winid, 'vert resize ' . l:width)
"  else
"    call win_execute(l:winid, 'resize ' . l:width)
"  endif
"
"  " The winheight value is lost when resizing buffers around
"  " Saving this value will allow proper resizing of 
"  " each widgets contained within each bar.
"  let self.winheight = winheight(win_id2win(self.getWinid()))
" 
"  call ide#debug(3, "Bar.resize",
"        \ "Bar width " . l:width .
"        \ " height " . self.winheight)
"endfun
"
"fun! s:Bar.calcHeight()
"  call ide#debug(3, "Bar.calcHeight",
"        \ "Calculating height for bar " . self.id)
"
"  if and(self.flags, s:Flags.VERT)
"    " Using vertical space, height is the whole window
"    let self.winheight = &lines
"  else
"    let self.winheight = float2nr(
"          \ (self.width_pct / 100.00) * &columns)
"  endif
"
"  call ide#debug(3, "Bar.calcHeight",
"        \ "Calculated height " . self.winheight)
"endfun
"
"fun! s:Bar.getMinWidth()
"  return float2nr((self.width_pct / 100.00) * &columns)
"endfun
"
"fun! s:Bar.openWidgets()
"  call ide#debug(3, "Bar.openWidgets",
"        \ "Opening widgets for bar " . self.id)
"
"  let l:widgets = g:IdeBars.getWidgetInstances(self)
"  
"  if len(l:widgets) == 0
"    call ide#debug(3, "Bar.openWidgets",
"          \ "There are no widgets to open. Bye")
"    return
"  endif
"  
"  " Open each individual widgets
"  for instance in l:widgets
"    call ide#debug(3, "Bar.openWidgets",
"          \ "Opening widget " . instance.widgetid)
"   
"    call instance.widget.run_event('open',
"          \ #{ barid: self.id })
"  endfor
"endfun
"
"fun! s:Bar.resizeWidgets()
"  call ide#debug(3, "Bar.resizeWidgets",
"        \ "Resize wdigets for bar " . self.id)
"  
"  let l:widgets = g:IdeBars.getWidgetInstances(self)
"  
"  " nothing to do if there are no widgets, right?
"  if len(l:widgets) == 0
"    call ide#debug(3, "Bar.resizeWidgets",
"          \ "There are not widgets to resize. Bye")
"    " The bar does not have any widgets but it has to be resized
"    " Resize the BAR itself, either vertically or horizontally
"    call self.resize()
"    return
"  endif
" 
"  " Start to resize from BOTTOM to TOP
"  "let l:widgets = reverse(copy(l:widgets))
" 
"  " if there is only one widget
"  " it's wise not to resize the only space available to 1
"  if len(l:widgets) > 1
"    call ide#debug(4, "Bar.resizeWidgets",
"          \ "Resizing multiple widgets...")
"    " some widgets take up all the space available
"    " such as terminal window, so resizing it to 1
"    " will actually resize the whole bar to 1
"    "call win_execute(self.getWinid(), 'resize 1') 
"    call win_execute(self.getWinid(), 'close!')
"    call self.setvar('hidden', 1)
"  endif
"  
"  let l:sum = 0.00
"  let l:resizeval = 0.00
"  " Iterate each widget and do the work
"  for instance in l:widgets
"    call ide#debug(4, "Bar.resizeWidgets",
"          \ "Resizing widget " . instance.widgetid)
"    
"    let l:widget = instance.widget
"    
"    " collect all the information needed to do proper resizing
"    let l:bufnr     = g:IdeWidgets.getvar(l:widget, 'bufnr',-1)
"    if l:bufnr == -1
"      echoerr "Widget bufnr is invalid"
"      return -1
"    endif
"    
"    let l:heightpct = g:IdeWidgets.getvar(l:widget,
"          \ 'minheightpct', 1)
"    
"    " Workaround to decrement bottom bar from total resizeval
"    let l:winheight = self.winheight
"    if self.id != 1
"      " Get bottom bar height
"      let l:bar = g:Ide.getLayout(self.layoutid).getBar(1)
"      if l:bar.state_ == 1
"        call ide#debug(4, "Bar.resizeWidgets",
"              \ "Warning: Using local winheight!")
"        let l:t = g:IdeBars.getWinHeight(l:bar)
"        let l:winheight = l:winheight - l:t
"      endif
"    endif
"    
"    let l:resizeval = float2nr(l:heightpct * l:winheight) - 2
"    
"    let l:diff = l:winheight - l:sum
"    let l:sum = l:sum + l:resizeval
"
"    
"    if l:resizeval > l:diff
"      call ide#debug(4, "Bar.resizeWidgets",
"            \ "Widget height is overflowing." . 
"            \ " sum " . string(l:sum) .
"            \ " actual winheight " . self.winheight .
"            \ " local winheight " . l:winheight .
"            \ " diff left " . string(l:diff))
"      let l:resizeval = l:diff
"    endif
"   
"    call ide#debug(4, "Bar.resizeWidgets",
"          \ "widget " . l:widget.id .
"          \ " minheightpct " . string(l:heightpct) .
"          \ " bar winheight " . self.winheight .
"          \ " bar local winheight " . l:winheight .
"          \ " resizeval " . string(l:resizeval) .
"          \ " bufnr " . l:bufnr .
"          \ " sum " . string(l:sum) .
"          \ " diff left " . string(l:diff))
"    
"    let l:bufwinid = bufwinid(l:bufnr)
"    call win_execute(bufwinid(l:bufnr),'resize ' . l:resizeval)
"    
"    call ide#debug(4, "Bar.resizeWidgets",
"          \ "win_execute(" . l:bufwinid .
"          \ ", resize " . string(l:resizeval) . ")")
"
"    if has_key(widget, 'opened')
"      call widget.opened()
"    endif
"
"  endfor
"endfun
"
"fun! s:Bar.closeWidgets()
"  call ide#debug(3, "Bar.closeWidgets",
"        \ "Close widgets for bar " . self.id)
"  
"  for instance in g:IdeBars.getWidgetInstances(self)
"    call ide#debug(4, "Bar.closeWidgets",
"          \ "Closing widget " . instance.widgetid)
"    
"    call instance.widget.run_event("close",
"          \ #{ barid: self.id})
"  endfor
"endfun
"
"fun! s:Bar.setvar(key, val)
"  let self.vars_[a:key] = a:val
"endfun
"
"fun! s:Bar.getvar(key, default)
"  return get(self.vars_, a:key, a:default)
"endfun
