" ==
" Description: basic rudimentary helper to handle ide functionality
" Maintainer: github.com/sdev75
" License: MIT
" ==

scriptencoding utf-8

if exists('loaded_ide')
  finish
endif

if v:version < 800
  echoerr "IDE plugin requires vim >= 8.0"
  finish
endif

let loaded_ide = 1

let g:Ide = {}
let g:Ide.settings_ = {}

function! g:Ide.getRootpath()
  return self.rootpath_
endfunction

function! g:Ide.setRootpath(...)
  let l:abspath = get(a:, 1, expand("%:p:h"))
  let self.rootpath_ = l:abspath
endfunction

function! g:Ide.jsonEscape(data)
  " NERDTree contains verbose formatted data
  " Unsetting the data helps to make the printing
  " possible without having to rely on more cleanups
  if exists('g:NERDTree')
    let l:data = deepcopy(a:data)
    for p in l:data
      for [key,val] in items(p)
        if key == "variables"
          for [kk, vv] in items(val)
            if kk == "NERDTree"
              unlet val[kk]
            endif
            if kk == "NERDTreeRoot"
              unlet val[kk]
            endif
          endfor
        endif
      endfor
    endfor
    let l:buf = string(l:data)
  else
    let l:buf = string(a:data)
  endif

  let l:buf = substitute(l:buf,"function('\\([0-9]\\+\\)')",
    \'"function(\1)"','g')
  let l:buf = substitute(l:buf,"'",'"','g')
  let l:buf = escape(l:buf,'"')
  let l:buf = substitute(l:buf,"{...}",'"[{...}]"','g')
  return l:buf
endfunction

function! g:Ide.dump(data)
  let l:buf = self.jsonEscape(a:data)
  return system('echo "' . l:buf . '" | python -m json.tool')
endfunction

function! g:Ide.createTerminalWindow()
  :term
endfunction

function! g:Ide.resizeTerminalWindow()
  let l:winid = self.getTerminalWinId()
  call win_execute(l:winid,'wincmd J')
  call win_execute(l:winid,'resize 10')
endfunction

function! g:Ide.getTerminalBufNr()
  return bufnr('!'.&shell)
endfunction

function! g:Ide.getTerminalWinNr()
  return winbufnr(self.getTerminalBufNr())
endfunction

function! g:Ide.getTerminalWinId()
  return win_getid(self.getTerminalWinNr())
endfunction

function! g:Ide.getTerminalWinHeight()
  let l:winid = self.getTerminalWinId()
  return winheight(winid)
endfunction

function! g:Ide.setTerminalWinHeight()
  let l:winid = self.getTerminalWinId()
  call win_execute(l:winid,'resize 10')
endfunction

function! g:Ide.toggleTerminal()

  let l:bufnr = self.getTerminalBufNr()
  if l:bufnr == -1
    " Create new Terminal window
    call self.createTerminalWindow()
    call self.resizeTerminalWindow()
    return
  endif

  let l:winid = self.getTerminalWinId()
 
  " Reopen terminal buffer to a new window
  if l:winid == 0
    execute ':sbuffer ' l:bufnr
    call self.resizeTerminalWindow()
    return
  endif

  " Hide terminal window, keep buffer intact
  call win_execute(l:winid,'hide') 
endfunction

function! g:Ide.closeTerminal()
  let l:winid = self.getTerminalWinId()
  if l:winid != 0
    call win_execute(l:winid,'close!')
  endif

  let l:bufnr = self.getTerminalBufNr()
  if l:bufnr == -1
    return
  endif

  execute ':bd! ' . l:bufnr
endfunction

function! g:Ide.onVimResized()
  if self.getTerminalBufNr() != -1
    call self.setTerminalWinHeight()
  endif
endfunction

function! g:Ide.onVimQuit()
  call self.closeTerminal()
endfunction

augroup Ide
  autocmd!
  autocmd VimEnter * :call g:Ide.setRootpath()
  autocmd VimResized * :call g:Ide.onVimResized()
  autocmd ExitPre * :call g:Ide.onVimQuit()
augroup END