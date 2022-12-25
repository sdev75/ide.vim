let s:Layouts = {}
let g:IdeLayouts = s:Layouts

let s:layouts = {}

let s:winlayout = #{
      \ panel: -1,
      \ editor: -1,
      \ leftbar: -1,
      \ rightbar: -1
      \ }

fun! s:Layouts.get(layoutid)
  let l:layout = get(s:layouts, a:layoutid, {})
  if len(keys(l:layout))
    return l:layout
  endif

  call g:Ide.debug(3, "Layouts.get",
          \ "Creating new instance for layoutid: " .. a:layoutid)

  " Assign default configuration data
  " One way to override this is to create the layout manually
  " The instance will be returned instead of reaching this line
  let l:layout = g:IdeLayout.new(a:layoutid, g:IdeLayoutConfig.new({}))
  let s:layouts[a:layoutid] = l:layout
  
  return l:layout
endfun

" Get a placeholder buffer used everywhere
fun! s:Layouts.getPlaceholderBufnr()
  let l:bufnr = bufnr("ide_placeholder")
  if l:bufnr == -1
    execute "silent! new"
    let l:bufnr = bufnr("$")
    call setbufvar(l:bufnr, "&buflisted", 0)
    call setbufvar(l:bufnr, "&number", 0)
    call setbufvar(l:bufnr, "&list", 0)
    call setbufvar(l:bufnr, "&readonly", 1)
    execute "silent! file ide_placeholder"
    call win_execute(bufwinid(l:bufnr), "close!")
  endif
  return l:bufnr
endfun

fun! s:Layouts.alignLeft(cfg)
  execute("set splitbelow splitright")
  execute("wincmd _ | wincmd |")
  execute("vsplit")
  execute("1wincmd h")
  execute("wincmd _ | wincmd |")
  execute("split")
  execute("1wincmd k")
  execute("wincmd _ | wincmd |")
  execute("vsplit")
  execute("1wincmd h")
  execute("wincmd w")
  execute("wincmd w")
  execute("wincmd w")
  execute("set nosplitbelow")
  execute("set nosplitright")
  execute("wincmd t")
  execute("set winminheight=0")
  execute("set winheight=1")
  execute("set winminwidth=0")
  execute("set winwidth=1")
  
  execute('3resize ' .float2nr(&lines * (a:cfg.panelHeightPct / 100.00)))
  execute('vert 1resize ' . float2nr(&columns * (a:cfg.leftBarWidthPct / 100.00)))
  execute('vert 4resize ' . float2nr(&columns * (a:cfg.rightBarWidthPct / 100.00)))
  
  execute("call win_gotoid(win_getid(1)) | set wfw")
  execute("call win_gotoid(win_getid(3)) | set wfh")
  execute("call win_gotoid(win_getid(4)) | set wfw")

endfun

fun! s:Layouts.alignRight(cfg)
  execute("set splitbelow splitright")
  execute("wincmd _ | wincmd |")
  execute("vsplit")
  execute("1wincmd h")
  execute("wincmd w")
  execute("wincmd _ | wincmd |")
  execute("split")
  execute("1wincmd k")
  execute("wincmd _ | wincmd |")
  execute("vsplit")
  execute("1wincmd h")
  execute("wincmd w")
  execute("wincmd w")
  execute("set nosplitbelow")
  execute("set nosplitright")
  execute("wincmd t")
  execute("set winminheight=0")
  execute("set winheight=1")
  execute("set winminwidth=0")
  execute("set winwidth=1")

  execute('4resize ' .float2nr(&lines * (a:cfg.panelHeightPct / 100.00)))
  execute('vert 1resize ' . float2nr(&columns * (a:cfg.leftBarWidthPct / 100.00)))
  execute('vert 3resize ' . float2nr(&columns * (a:cfg.rightBarWidthPct / 100.00)))
  
  execute("call win_gotoid(win_getid(1)) | set wfw")
  execute("call win_gotoid(win_getid(3)) | set wfw")
  execute("call win_gotoid(win_getid(4)) | set wfh")
 
  " Return a struct having list of matching winid
  " Useful for processing further
  let l:res = copy(s:winlayout)
  let l:res.panel = win_getid(4)
  let l:res.editor = win_getid(2)
  let l:res.leftbar = win_getid(1)
  let l:res.rightbar = win_getid(3)
  return l:res
endfun

fun! s:Layouts.alignCenter(cfg)
  execute("set splitbelow splitright")
  execute("wincmd _ | wincmd |")
  execute("vsplit")
  execute("wincmd _ | wincmd |")
  execute("vsplit")
  execute("2wincmd h")
  execute("wincmd w")
  execute("wincmd _ | wincmd |")
  execute("split")
  execute("1wincmd k")
  execute("wincmd w")
  execute("wincmd w")
  execute("set nosplitbelow")
  execute("set nosplitright")
  execute("wincmd t")
  execute("set winminheight=0")
  execute("set winheight=1")
  execute("set winminwidth=0")
  execute("set winwidth=1")
  
  execute('3resize ' .float2nr(&lines * (a:cfg.panelHeightPct / 100.00)))
  execute('vert 1resize ' . float2nr(&columns * (a:cfg.leftBarWidthPct / 100.00)))
  execute('vert 4resize ' . float2nr(&columns * (a:cfg.rightBarWidthPct / 100.00)))

  execute("call win_gotoid(win_getid(1)) | set wfw")
  execute("call win_gotoid(win_getid(3)) | set wfh")
  execute("call win_gotoid(win_getid(4)) | set wfw")
endfun

fun! s:Layouts.alignJustify(cfg)
  execute("set splitbelow splitright")
  execute("wincmd _ | wincmd |")
  execute("split")
  execute("1wincmd k")
  execute("wincmd _ | wincmd |")
  execute("vsplit")
  execute("wincmd _ | wincmd |")
  execute("vsplit")
  execute("2wincmd h")
  execute("wincmd w")
  execute("wincmd w")
  execute("wincmd w")
  execute("set nosplitbelow")
  execute("set nosplitright")
  execute("wincmd t")
  execute("set winminheight=0")
  execute("set winheight=1")
  execute("set winminwidth=0")
  execute("set winwidth=1")

  execute('4resize ' .float2nr(&lines * (a:cfg.panelHeightPct / 100.00)))
  execute('vert 1resize ' . float2nr(&columns * (a:cfg.leftBarWidthPct / 100.00)))
  execute('vert 3resize ' . float2nr(&columns * (a:cfg.rightBarWidthPct / 100.00)))

  execute("call win_gotoid(win_getid(1)) | set wfw")
  execute("call win_gotoid(win_getid(3)) | set wfw")
  execute("call win_gotoid(win_getid(4)) | set wfh")
endfun

fun! s:Layouts.draw(layoutConfig)
  " Get default placeholder for all windows
  let bufnr = self.getPlaceholderBufnr()

  " Close all except one and assign it the placeholder
  execute("only! | b!" .. bufnr)

  let align = a:layoutConfig.panelAlignment
  " Perform the alignment of choice
  if align ==? "left"
    call self.alignLeft(a:layoutConfig)
  elseif align ==? "right"
    let winlayout = self.alignRight(a:layoutConfig)
  elseif align ==? "center"
    call self.alignCenter(a:layoutConfig)
  elseif align ==? "justify"
    call self.alignJustify(a:layoutConfig)
  endif

  call g:Ide.debug(3, "test", string(winlayout))
  if a:layoutConfig.panelVisibility == 0
    call win_execute(winlayout.panel, 'close!')
  endif
  if a:layoutConfig.leftBarVisibility == 0
    call win_execute(winlayout.leftbar, 'close!')
  endif
  if a:layoutConfig.rightBarVisibility == 0
    call win_execute(winlayout.rightbar, 'close!')
  endif
endfun
