let s:Editors = {}
let g:IdeEditors = s:Editors

let s:editors = {}

" Get editor by layoutId
fun! s:Editors.get(layoutid)
  
  " Try and get editor from an existing instance
  let l:editor = get(s:editors, a:layoutid, {})
  if len(keys(l:editor)) == 0
    call g:Ide.debug(3, "Editors.get",
          \ "Returning existing instance for layoutid " .. a:layoutid)
    " Create new instance and store it in dictionary
    let l:editor = g:IdeEditor.new(a:layoutid)
    let s:editors[a:layoutid] = l:editor
  endif

  " Ensure the editor is properly initialized at all times
  call l:editor.init()
endfun

