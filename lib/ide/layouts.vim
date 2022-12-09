let s:Layouts = {}
let g:IdeLayouts = s:Layouts

let s:MapStickySeq = [
      \ [3,2,1,0], [2,0,1,3], [0,3,2,1], [2,1,3,0] ]
let s:MapIndex = ["left","bottom","top","right"]
let s:Map = #{
      \ left:    #{ idx: 0, flags: g:IdeBarFlags.LEFT  },
      \ bottom:  #{ idx: 1, flags: g:IdeBarFlags.BOTTOM },
      \ top:     #{ idx: 2, flags: g:IdeBarFlags.TOP },
      \ right:   #{ idx: 3, flags: g:IdeBarFlags.RIGHT }
      \ }

let s:layouts = {}

fun! s:Layouts.get(layoutid)
  let l:layout = get(s:layouts, a:layoutid, {})
  if len(keys(l:layout))
    call g:Ide.debug(3, "Layouts.get",
          \ "Returning existing instance of layoutid " .. a:layoutid)
    return l:layout
  endif

  call g:Ide.debug(3, "Layouts.get",
          \ "Creating new instance for layoutid: " .. a:layoutid)
  let l:layout = g:IdeLayout.new(a:layoutid)
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

fun! s:Layouts.alignLeft()
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
  
  execute('1resize ' . ((&lines * 42 + 27) / 55))
  execute( 'vert 1resize ' . ((&columns * 35 + 89) / 179))
  execute( '2resize ' . ((&lines * 42 + 27) / 55))
  execute( 'vert 2resize ' . ((&columns * 86 + 89) / 179))
  execute( '3resize ' . ((&lines * 10 + 27) / 55))
  execute( 'vert 3resize ' . ((&columns * 122 + 89) / 179))
  execute( 'vert 4resize ' . ((&columns * 56 + 89) / 179))
  
  execute("call win_gotoid(win_getid(1)) | set wfw")
  execute("call win_gotoid(win_getid(3)) | set wfh")
  execute("call win_gotoid(win_getid(4)) | set wfw")
endfun

fun! s:Layouts.alignRight()
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

  execute('vert 1resize ' . ((&columns * 41 + 100) / 200))
  execute('2resize ' . ((&lines * 42 + 28) / 56))
  execute('vert 2resize ' . ((&columns * 87 + 100) / 200))
  execute('3resize ' . ((&lines * 42 + 28) / 56))
  execute('vert 3resize ' . ((&columns * 70 + 100) / 200))
  execute('4resize ' . ((&lines * 11 + 28) / 56))
  execute('vert 4resize ' . ((&columns * 158 + 100) / 200))

  execute("call win_gotoid(win_getid(1)) | set wfw")
  execute("call win_gotoid(win_getid(3)) | set wfw")
  execute("call win_gotoid(win_getid(4)) | set wfh")
endfun

fun! s:Layouts.alignCenter()
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
  
  execute('vert 1resize ' . ((&columns * 38 + 90) / 181))
  execute('2resize ' . ((&lines * 41 + 27) / 55))
  execute('vert 2resize ' . ((&columns * 85 + 90) / 181))
  execute('3resize ' . ((&lines * 11 + 27) / 55))
  execute('vert 3resize ' . ((&columns * 85 + 90) / 181))
  execute('vert 4resize ' . ((&columns * 56 + 90) / 181))

  execute("call win_gotoid(win_getid(1)) | set wfw")
  execute("call win_gotoid(win_getid(3)) | set wfh")
  execute("call win_gotoid(win_getid(4)) | set wfw")
endfun

fun! s:Layouts.alignJustify()
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

  execute('vert 1resize ' . ((&columns * 41 + 100) / 200))
  execute('2resize ' . ((&lines * 42 + 28) / 56))
  execute('vert 2resize ' . ((&columns * 87 + 100) / 200))
  execute('3resize ' . ((&lines * 42 + 28) / 56))
  execute('vert 3resize ' . ((&columns * 70 + 100) / 200))
  execute('4resize ' . ((&lines * 11 + 28) / 56))
  execute('vert 4resize ' . ((&columns * 158 + 100) / 200))

  execute("call win_gotoid(win_getid(1)) | set wfw")
  execute("call win_gotoid(win_getid(3)) | set wfw")
  execute("call win_gotoid(win_getid(4)) | set wfh")
endfun

fun! s:Layouts.draw(layoutid, align)
  " Get default placeholder for all windows
  let l:bufnr = self.getPlaceholderBufnr()

  " Close all except one and assign it the placeholder
  execute("only! | b!" .. l:bufnr)
  
  " Align accordingly
  if a:align ==? "left"
    call self.alignLeft()
  elseif a:align ==? "right"
    call self.alignRight()
  elseif a:align ==? "center"
    call self.alignCenter()
  elseif a:align ==? "justify"
    call self.alignJustify()
  endif
 
  " Resize the window to fit the requirements
  "call self.resizeWindows()
endfun

fun! s:Layouts.resizeWindows()
  execute('vert 1resize ' . ((&columns * 41 + 100) / 200))
  execute('2resize ' . ((&lines * 42 + 28) / 56))
  execute('vert 2resize ' . ((&columns * 87 + 100) / 200))
  execute('3resize ' . ((&lines * 42 + 28) / 56))
  execute('vert 3resize ' . ((&columns * 70 + 100) / 200))
  execute('4resize ' . ((&lines * 11 + 28) / 56))
  execute('vert 4resize ' . ((&columns * 158 + 100) / 200))

  execute("call win_gotoid(win_getid(1)) | set wfw")
  execute("call win_gotoid(win_getid(3)) | set wfw")
  execute("call win_gotoid(win_getid(4)) | set wfh")
endfun
