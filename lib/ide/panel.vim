let s:Panel = {}
let g:IdePanel = s:Panel

let s:panel = #{
      \ tabs: {},
      \ visibility: -1,
      \ layoutid: -1,
      \ }

fun! s:Panel.new(layoutid)
  call g:Ide.debug(3, "Layout.new",
        \ "New layout created with layoutid " .. a:layoutid)
  let l:panel = deepcopy(s:panel)
  let l:panel.layoutid = a:layoutid
  return l:panel
endfun

fun! s:Panel.get___()
  if len(keys(s:panel))
    call g:Ide.debug(3, "Panel.get",
          \ "Returning existing instance")
    return s:panel
  endif

  call g:Ide.debug(3, "Panel.get",
          \ "Creating new instance")
  let s:panel = self.new(a:layoutid)
  return s:panel
endfun

fun! s:Panel.addTab(id, title, bufnr)
  
endfun

let s:PanelTab = #{ id: -1, title: "" }
