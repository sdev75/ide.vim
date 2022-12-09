let s:Panel = {}
let s:IdePanel = s:Panel

let s:panel = {}

fun! s:Panel.get()
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

fun! s:Panel.new(layoutid)
  call g:Ide.debug(3, "Layout.new",
        \ "New layout created with layoutid " .. a:layoutid)
  let l:panel = {}
  let l:panel.alignment = "right"
  return l:panel
endfun
