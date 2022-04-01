let s:Layout = {}
let g:IdeLayout = s:Layout

let s:MapStickySeq = [
      \[3,2,1,0], [2,0,1,3], [0,3,2,1], [2,1,3,0] ]
let s:MapIndex = ["left","bottom","top","right"]
let s:Map = #{
      \left:    #{ idx: 0, flags: g:IdeBarFlags.LEFT  },
      \bottom:  #{ idx: 1, flags: g:IdeBarFlags.BOTTOM },
      \top:     #{ idx: 2, flags: g:IdeBarFlags.TOP },
      \right:   #{ idx: 3, flags: g:IdeBarFlags.RIGHT }
      \}

fun! s:getBarWidthPct(pos)
  let l:key = substitute(a:pos, '^.', 'IdeBarMinWidthPct\u&', '')
  return get(g:, l:key)
endfun

fun! s:Layout.new()
  let l:obj = copy(self)
  call l:obj['init_']()
  return l:obj
endfun

fun! s:Layout.init_()
  " Left, Right, Bottom, Top, ...
  let self.map = deepcopy(s:Map)
  let self.bars = []
  for idx in range(0,len(s:MapIndex)-1)
    let l:pos = s:MapIndex[idx]
    let l:bar = g:IdeBar.new()
    call l:bar.setFlags(self.map[l:pos].flags)
    call l:bar.setWidthPct(s:getBarWidthPct(l:pos))
    call add(self.bars, l:bar)
  endfor
  "let l:termpos = get(g:, 'IdeTerminalBar', '')
  "if len(l:termpos) != 0
  "  call self.setBarCallback(l:termpos, 'open', self.initTerm)
  "endif
endfun

fun! s:Layout.openBar(idx)
  let l:bufnr = g:IdeBuffer.bufnr('empty', 'scratch')
  call self.bars[a:idx].open(l:bufnr)
  call self.alignBars()
  call self.resizeBars()
  call self.openWidgets()
endfun

fun! s:Layout.closeBar(idx)
  call self.closeWidgets()
  call self.bars[a:idx].close()
  call self.alignBars()
  call self.resizeBars()
endfun

fun! s:Layout.toggleBar(pos)
  let l:item = get(self.map, a:pos)
  let l:idx = l:item.idx
  if self.bars[l:idx].getWinid()
    call self.closeBar(l:idx)
    return
  endif
  call self.openBar(l:idx)
endfun

fun! s:Layout.getBar(id)
  return self.bars[a:id]
endfun

fun! s:Layout.setBarCallback(pos, name, cb)
  let l:item = get(self.map, a:pos)
  let l:idx = l:item.idx
  call self.bars[l:idx].setCallback(a:name, a:cb)
endfun

fun! s:Layout.alignBars()
  let l:range = s:MapStickySeq[g:IdeBarStickyMode]
  for idx in l:range
    call self.bars[idx].align()
  endfor
endfun

fun! s:Layout.resizeBars()
  for idx in range(0, 3)
    call self.bars[idx].resize()
  endfor
endfun

fun! s:Layout.openWidgets()
  for idx in range(0, 3)
    call self.bars[idx].openWidgets()
  endfor
endfun

fun! s:Layout.closeWidgets()
  for idx in range(0, 3)
    call self.bars[idx].closeWidgets()
  endfor
endfun

fun! s:Layout.initTerm()
  call g:IdeTerminal.init(self.id, "console")
endfun

fun! s:Layout.cleanup()
  call g:IdeTerminal.destroy(self.id, "console")
endfun

fun! s:Layout.getBarId(pos)
  return get(self.map, a:pos).idx
endfun

fun! s:Layout.addWidget(pos, widgetid)
  let l:barid = self.getBarId(a:pos)
  let l:widget = g:Ide.getWidget(a:widgetid)
  if empty(l:widget)
    echoerr "Widget not registered with id: " . a:widgetid 
    return -1
  endif

  let l:widget_copy = copy(l:widget)
  let l:widget_copy.layoutid = self.id
  let l:widget_copy.barid = l:barid
  call self.bars[l:barid].addWidget(l:widget_copy)
endfun

fun! s:Layout.getWidgets(pos)
  let l:item = get(self.map, a:pos)
  let l:idx = l:item.idx
  return self.bars[l:idx].getWidgets()
endfun

" support for multi layouts requires implementation
augroup IdeLayout
  autocmd!
  autocmd User OnVimResized
        \ call g:Ide.getLayout().resizeBars()
  autocmd User OnVimExitPre
        \ call g:Ide.getLayout().cleanup()
augroup END
