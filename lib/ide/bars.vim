let s:Bars = {}
let g:IdeBars = s:Bars

fun! s:Bars.getWidgetInstances(bar)
  call ide#debug(4, "IdeBars.getWidgetInstances",
        \ " bar " . a:bar.id)

  return filter(copy(g:IdeWidgets.getInstances()),
        \ "v:val.layoutid == " . a:bar.layoutid .
        \ " && v:val.barid == " . a:bar.id)
endfun

fun! s:Bars.getWidgetInstancesById(bar, widgetid)
  call ide#debug(4, "IdeBars.getWidgetInstancesById",
        \ "barid" . a:bar.id . 
        \ " widgetid " . a:widgetid)

  return filter(copy(self.getWidgetInstances()),
        \ "v:val.widgetid ==# " . a:widgetid)
endfun

fun! s:Bars.getWinHeight(bar)
  call ide#debug(4, "IdeBars.getWidgetInstancesById",
        \ "barid" . a:bar.id . 
        \ " layoutid " . a:bar.layoutid)
  return a:bar.winheight
endfun
