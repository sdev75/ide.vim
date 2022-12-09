let s:Bars = {}
let g:IdeBars = s:Bars

let s:bars = {}

fun! s:Bars.get(barid)
  let l:bar = get(s:bars, a:barid, {})
  if len(keys(l:bar))
    call g:Ide.debug(3, "Bars.get",
          \ "Returning existing instance of barid " .. a:barid)
    return l:bar
  endif

  call g:Ide.debug(3, "Bars.get",
          \ "Creating new instance for barid: " .. a:barid)
  let l:barid = g:IdeBar.new(a:barid)
  let s:bars[a:barid] = l:bar
  return l:bar
endfun

" Returns an instance of the primary bar
" Usually located on the left side
fun! s:Bars.getPrimaryBar()
  return self.get(0)
endfun

" Returns an instance of the secondary bar
" Usually located on the right side
fun! s:Bars.getSecondaryBar()
  return self.get(1)
endfun

fun! s:Bars.getWidgetInstances(bar)
  call ide#debug(4, "IdeBars.getWidgetInstances",
        \ " bar " . a:bar.id .
        \ " bar.layoutid " . a:bar.layoutid)

  return filter(copy(g:IdeWidgets.getInstances()),
        \ "v:val.layoutid == " . a:bar.layoutid .
        \ " && v:val.barid == " . a:bar.id)
endfun

fun! s:Bars.getWidgetInstancesById(bar, widgetid)
  call ide#debug(4, "IdeBars.getWidgetInstancesById",
        \ "barid" . a:bar.id . 
        \ " widgetid " . a:widgetid)
  " Filter out widgets having layoutid equal to -1
  " These are used only for lazily instantiating instances
  " during the layout init procedure
  return filter(copy(self.getWidgetInstances()),
        \ "v:val.layoutid != -1" .
        \ "&& v:val.widgetid ==# " . a:widgetid)
endfun

fun! s:Bars.getWinHeight(bar)
  call ide#debug(4, "IdeBars.getWidgetInstancesById",
        \ "barid" . a:bar.id . 
        \ " layoutid " . a:bar.layoutid)
  return a:bar.winheight
endfun
