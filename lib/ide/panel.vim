let s:Panel = {}
let g:IdePanel = s:Panel

let s:panel = #{
      \ tabs: {},
      \ visibility: -1,
      \ layoutid: -1,
      \ winid: -1,
      \ }

let s:PanelTab = #{ id: -1, title: "", action: {} }
let s:PanelTabs = {}

fun! s:Panel.new(layoutid)
  call g:Ide.debug(3, "Panel.new",
        \ "New panel instance for layoutid " .. a:layoutid)
  let panel = deepcopy(s:Panel)
  let panel = extend(panel, s:panel)
  let panel.layoutid = a:layoutid

  call panel.addTab(1, 'Terminal', expand('<SID>')..'showTerminal')
  call panel.addTab(2, 'Logs', expand('<SID>')..'showLogs')
  return panel
endfun

fun! s:Panel.setWinId(winid)
  let self.winid = a:winid
endfun

fun! s:Panel.addTab(id, title, action) 
  let tab = copy(s:PanelTab)
  let tab.id = a:id
  let tab.title = escape(a:title, ' ')
  let tab.action = a:action
  
  call s:PanelTabs.set(self, tab)
endfun

fun! s:Panel.drawTabs()
  call s:PanelTabs.redraw(self)
endfun

fun! s:PanelTabs.new()
  let tabs = deepcopy(self)
  return tabs
endfun

fun! s:PanelTabs.set(panel, tab)
  call g:Ide.debug(3, "PanelTabs.set",
        \ "Setting tab for panel " .. string(a:tab))
  
  " Save tab in panel's tabs dict by tabid 
  let a:panel.tabs[a:tab.id] = a:tab
endfun

fun! s:PanelTabs.redraw(panel)
  call g:Ide.debug(3, "PanelTabs.redraw",
        \ "Redrawing tabs for panel")
  " Get winid of the panel
  let winid = a:panel.winid
  
  " Delete all previous WinBar menu entries
  call win_execute(winid, 'aunmenu WinBar')

  " Iterate through all the tabs elements
  " append WinBar menu entry for each element
  for key in keys(a:panel.tabs)
    let tab = a:panel.tabs[key]
    call win_execute(winid, 'nnoremenu 1.10 WinBar.' ..
          \ tab.title .. 
          \ ' :call ' .. tab.action .. '()<CR>')
  endfor
endfun
