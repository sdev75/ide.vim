let s:Layouts = {}
let g:IdeLayouts = s:Layouts

let s:layouts = {}

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
  let l:bufnr = self.getPlaceholderBufnr()

  " Close all except one and assign it the placeholder
  if exists("g:A")
    return
  endif
  execute("only! | b!" .. l:bufnr)
  "let g:A = 1

  let l:align = a:layoutConfig.panelAlignment
  " Perform the alignment of choice
  if l:align ==? "left"
    call self.alignLeft(a:layoutConfig)
  elseif l:align ==? "right"
    call self.alignRight(a:layoutConfig)
  elseif l:align ==? "center"
    call self.alignCenter(a:layoutConfig)
  elseif l:align ==? "justify"
    call self.alignJustify(a:layoutConfig)
  endif
endfun
