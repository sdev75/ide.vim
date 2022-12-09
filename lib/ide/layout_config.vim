let s:LayoutConfig = {}
let g:IdeLayoutConfig = s:LayoutConfig

fun! s:LayoutConfig.new()
  let l:config = deepcopy(self)
  
  " default panel settings
  let l:config.panelAlignment = "right"
  let l:config.panelVisibility = 0

  " default sidebar settings
  let l:config.leftBarVisibility = 0
  let l:config.rightBarVisibility = 0

  return l:config
endfun
