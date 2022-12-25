let s:LayoutConfig = #{
      \ panelAlignment: "right",
      \ panelVisibility: 1,
      \ panelHeightPct: 25,
      \ leftBarVisibility: 1,
      \ leftBarWidthPct: 20,
      \ rightBarVisibility: 1,
      \ rightBarWidthPct: 35,
      \ }

let g:IdeLayoutConfig = s:LayoutConfig

" CfgOverride will be merged with the return value
" Useful when setting multiple properties at once
fun! s:LayoutConfig.new(cfgOverride = {})
  let cfg = deepcopy(self)
  return extend(cfg, a:cfgOverride)
endfun
