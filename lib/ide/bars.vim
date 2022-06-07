let s:Bars = {}
let g:IdeBars = s:Bars

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
