let s:LayoutConfig = {}
let g:IdeLayoutConfig = s:LayoutConfig

fun! s:LayoutConfig.new()
  let l:cfg = deepcopy(self)
  
  " default panel settings
  let l:cfg.panelAlignment = "right"
  let l:cfg.panelVisibility = 0
  
  " Set the height percentage
  let l:cfg.panelHeightPct = 50.0

  " default sidebar settings
  let l:cfg.leftBarVisibility = 0
  let l:cfg.rightBarVisibility = 0

  return l:cfg
endfun
