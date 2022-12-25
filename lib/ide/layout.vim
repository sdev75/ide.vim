let s:Layout = {}
let g:IdeLayout = s:Layout

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

fun! s:Layout.getConfig()
  return self.config
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

  " initialize panel
  let self.panel = g:IdePanel.new(a:layoutid)
  return
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

"fun! s:Layout.toggleTerminal(pos)
"  call self.toggleBar(a:pos)
"endfun
"
"fun! s:Layout.getBar(id)
"  return self.bars[a:id]
"endfun
"
"fun! s:Layout.getBarPosition(barid)
"  let l:map = filter(copy(s:Map), "v:val['idx'] == " . a:barid)
"  return string(keys(l:map)[0])
"endfun
"
"fun! s:Layout.alignBars()
"  let l:range = s:MapStickySeq[g:IdeBarStickyMode]
"  for idx in l:range
"    call self.bars[idx].align()
"  endfor
"endfun
"
"fun! s:Layout.getBarId(pos)
"  return get(self.map, a:pos).idx
"endfun
"
"fun! s:Layout.getBars()
"  return self.bars
"endfun
"
fun! s:Layout.setvar(key, val)
  let self.vars_[a:key] = a:val
endfun

fun! s:Layout.getvar(key, default)
  return get(self.vars_, a:key, a:default)
endfun

fun! s:Layout.getPanel()
  return self.panel
endfun

" This function merely changes the layout's configuration
" property such as `panelVisibility` to either 1 or 0.
" This property is then read during the drawing process
"
" Ex. Layout.toggleLayoutVisibility('leftBar')
fun! s:Layout.toggleLayoutVisibility(name)
  call g:Ide.debug(4, "Layout.toggleLayoutVisibility",
        \ "Changing layout visibility for " .. a:name)
  let cfg = self.getConfig()
  let key = a:name .. "Visibility"
  if cfg[key] == 1
    let cfg[key] = 0
  else
    let cfg[key] = 1
  endif
  call g:Ide.debug(4, "Layout.toggleLayoutVisibility",
    \ "layoutConfig has been updated to: " .. string(cfg))
endfun

