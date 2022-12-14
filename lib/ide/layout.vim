let s:Layout = {}
let g:IdeLayout = s:Layout

let s:MapStickySeq = [
      \ [3,2,1,0], [2,0,1,3], [0,3,2,1], [2,1,3,0] ]
let s:MapIndex = ["left","bottom","top","right"]
let s:Map = #{
      \ left:    #{ idx: 0, flags: g:IdeBarFlags.LEFT  },
      \ bottom:  #{ idx: 1, flags: g:IdeBarFlags.BOTTOM },
      \ top:     #{ idx: 2, flags: g:IdeBarFlags.TOP },
      \ right:   #{ idx: 3, flags: g:IdeBarFlags.RIGHT }
      \ }

fun! s:getBarWidthPct(pos)
  let l:key = substitute(a:pos, '^.', 'IdeBarMinWidthPct\u&', '')
  return get(g:, l:key)
endfun

fun! s:Layout.new(layoutid, config)
  call g:Ide.debug(3, "Layout.new",
        \ "New layout created with layoutid " .. a:layoutid)
  let l:layout = deepcopy(self)
  let l:layout.id = a:layoutid
  let l:layout.config = a:config
  call l:layout.init_(a:layoutid)
  return l:layout
endfun

fun! s:Layout.getEditor()
  call g:Ide.debug(3, "Layout.getEditor",
        \ "layoutid " .. self.id)
  let l:editor = g:IdeEditors.get(self.id)
  return l:editor
endfun

fun! s:Layout.setConfig(config)
  call g:Ide.debug(3, "Layout.setConfig",
        \ "layoutid " .. self.id)
  let self.config = a:config
endfun

fun! s:Layout.draw()
  return g:IdeLayouts.draw(self.config.panelAlignment)
endfun

" Return list of widgets that belong to this layout
" including widgets that are applied to all layouts (-1)
fun! s:Layout.getWidgetInstances()
  return filter(copy(g:IdeWidgets.getInstances()),
        \ "v:val.layoutid == -1 || v:val.layoutid == " . self.id)
endfun

fun! s:Layout.init_(layoutid)
  call g:Ide.debug(3, "Layout.init_",
        \ "Init called for layoutid " .. a:layoutid)
  
  let self.map = deepcopy(s:Map)
  let self.bars = []
  let self.vars_ = {}
  for idx in range(0,len(s:MapIndex)-1)
    let l:pos = s:MapIndex[idx]
    let l:bar = g:IdeBar.new(idx, a:layoutid)
    call l:bar.setFlags(self.map[l:pos].flags)
    call l:bar.setWidthPct(s:getBarWidthPct(l:pos))
    call add(self.bars, l:bar)
  endfor
 
  "call ide#debug(2, "Layout.init_",
  "      \ "Initializing layout's widgets")

  "" Initialize all layout's widgets
  "" When a widget instance has layout set to -1
  "" it means that it will be available on all layouts
  "for instance in self.getWidgetInstances()
  "  call ide#debug(4, "Layout.init_",
  "        \ "Init instance " . instance.widgetid .
  "        \ " layoutid " . instance.layoutid .
  "        \ " barid " . instance.barid)

  "  " Skip deepcopy if instance has already been copied
  "  if !empty(instance.widget)
  "    echoerr "Instance already processed. Oops"
  "    continue
  "  endif

  "  " Grab the widget from the registry
  "  " All widgets are registered when loaded
  "  " If a widget is not registered, it is simply not 
  "  " available for use and an error shows up
  "  let l:widget = g:IdeWidgets.get(instance.widgetid)
  "  if empty(l:widget)
  "    return -1
  "  endif

  "  if instance.layoutid == -1
  "    call ide#debug(4, "Layout.init_",
  "          \ "Creating widget instance for virtual layout " .
  "          \ self.id . 
  "          \ " widgetid " . instance.widgetid)
  "    " Create a copy of the current instance
  "    " with the current layoutid and the same barid
  "    let l:instance_copy = copy(l:instance)
  "    let l:instance_copy.layoutid = self.id

  "    " Deepcopy the widget using instance copy metadata
  "    let l:widget_copy           = deepcopy(l:widget)
  "    let l:widget_copy.layoutid  = instance_copy.layoutid
  "    let l:widget_copy.barid     = instance_copy.barid
  "    
  "    let l:instance_copy.widget = l:widget_copy
  "   
  "    " Add instance to list of instances
  "    " Layout -1 will be filtered out when querying data
  "    call g:IdeWidgets.addInstance_(l:instance_copy)
  "    continue
  "  endif
  "  " All instances are lazy loaded when a layout
  "  " is created
  "  call ide#debug(3, "Layout.init_",
  "        \ "Creating instance for " . instance.widgetid)
  "  " Deepcopy the widget using instance metadata
  "  let l:widget_copy           = deepcopy(l:widget)
  "  let l:widget_copy.layoutid  = instance.layoutid
  "  let l:widget_copy.barid     = instance.barid
  "  
  "  " Assign unique widget to current instance
  "  let instance.widget = l:widget_copy
  "endfor
endfun

fun! s:Layout.toggleTerminal(pos)
  call self.toggleBar(a:pos)
endfun

fun! s:Layout.getBar(id)
  return self.bars[a:id]
endfun

fun! s:Layout.getBarPosition(barid)
  let l:map = filter(copy(s:Map), "v:val['idx'] == " . a:barid)
  return string(keys(l:map)[0])
endfun

fun! s:Layout.alignBars()
  let l:range = s:MapStickySeq[g:IdeBarStickyMode]
  for idx in l:range
    call self.bars[idx].align()
  endfor
endfun

fun! s:Layout.getBarId(pos)
  return get(self.map, a:pos).idx
endfun

fun! s:Layout.getBars()
  return self.bars
endfun

fun! s:Layout.setvar(key, val)
  let self.vars_[a:key] = a:val
endfun

fun! s:Layout.getvar(key, default)
  return get(self.vars_, a:key, a:default)
endfun

" @deprecated
" This is NOT reliable as there might be room for more sub levels.
" A better solution has already been implemented.
" This function will be deleted in the future
fun! s:Layout.getWidth()
  let l:list = winlayout(self.id)
  call g:Ide.debug(3, "Layout.getWidth", l:list)
  
  let l:width = -1
  
  " Only leaf one window
  " ['leaf', <ID>]
  if l:list[0] ==? "leaf"  && type(l:list[1]) == v:t_number
  
    let l:width = winwidth(l:list[1])
  
  " Column with multiple windows
  elseif l:list[0] ==? "col" && type(l:list[1]) == v:t_list
   
    let l:col = l:list[1]
    " Scenario#1
    " -------------------------------------------------
    " [ 'col', [['leaf', <ID>], ['leaf', <ID>]] ] 
    "   -----   --------------  -------------
    "
    "   +-------+--------------+
    "   | col.0 | leaf.0, <ID> |
    "   +-------+--------------+
    "   | col.0 | leaf.1, <ID> |
    "   +----------------------+
    " The total width can be calculated from the 1st leaf
    "
    "
   
    " Scenario#2 
    " [ col, [ [row, [ [leaf,ID],[leaf,ID] ] ], [leaf,ID] ]]
    "
    " +-------+-------------------+
    " | col.0 |      row.0        |
    " |       |  leaf0.0, leaf0.1 |
    " +-------+-------------------+
    " | col 0 |       leaf.1      |
    " +-------+-------------------+
    "
    " The width can be calculated again using the 1st row or leaf
    
    " See scenario#2
    " Check if the dealing with a row
    if l:col[0][0] == "row"
      let l:row = l:col[0][1]
      " Foreach all the leaves within the row as per Scenario#2
      for i in range(0, len(l:row) - 1)
        let l:winid = l:row[i][1]
        let l:winwidth = winwidth(l:winid)
        call g:Ide.debug(5, "Layout.getWidth",
              \ "winid:" .. l:winid .. " width:" .. l:winwidth)
        let l:width = l:width + winwidth(l:row[i][1])
      endfor

    " See scenario#1
    elseif l:col[0][0] == "leaf"
        let l:winid = l:col[0][1]
        let l:winwidth = winwidth(l:winid)
        call g:Ide.debug(5, "Layout.getWidth",
              \ "winid:" .. l:winid .. " width:" .. l:winwidth)
        let l:width = winwidth(l:col[0][1])
    endif
    
  elseif l:list[0] ==? "row" && type(l:list[1]) == v:t_list
    
    " Rows can contain one or more leaves, including other cols
    " In the event of a col the same logic will be applied as per 
    " scenario#2 to get the sum of the leaves within the col
    " The main difference between Rows and Cols is that the former 
    " must be iterated over all of the leaves and cols in order to 
    " calculate the total width
    "
    " Row layout example
    " +--------------------------------------+
    " |        |   col    |    col           |
    " | [leaf] |          |                  |
    " |        |          |      [leaf]      |
    " |        |  [leaf]  |                  |
    " |        |          +------------------+
    " |        |          |    row           |
    " |        |----------|         |        |
    " |        |          |         |   col  |
    " |        |          |  [leaf] |        |
    " |        |  [leaf]  |         | [leaf] |
    " |        |          |         |--------|
    " |        |          |         | [leaf] |
    " |        |          |         |        |
    " +--------------------------------------+ 
    
    " Items may contain either [leaf,ID] or [col, [array]]
    let l:items = l:list[1]

    " Foreach all items within the list, either LEAF or COL->ARRAY
    for i in range(0, len(l:items) - 1)
      let l:item = l:items[i]
 
      if l:item[0] ==? "leaf"
        let l:winid = l:item[1]
        let l:winwidth = winwidth(l:winid)
        let l:width = l:width + l:winwidth
        call g:Ide.debug(5, "Layout.getWidth",
              \ "winid:" .. l:winid .. " width:" .. l:winwidth)
        continue
      endif

      " The first window is enough to perform the calculation
      if l:item[0] ==? "col"
        let l:winid = l:item[1][0][1]
        let l:winwidth = winwidth(l:winid)
        let l:width = l:width + l:winwidth
        call g:Ide.debug(5, "Layout.getWidth",
              \ "winid:" .. l:winid .. " width:" .. l:winwidth)
        continue
      endif
    endfor
  endif

  call g:Ide.debug(3, "Layout.getWidth", "Calculated width is " .. l:width)
  return l:width
endfun
