# ide.vim
vim script for handling a rudimentary IDE implementation

## Installation

It's recommend to use VIM 8 packadd functionality.

```vim
packadd ide
if exists('Ide')
  " do remapping
endif
```

## Basic usage

Toggle Terminal:
```vim
nnoremap <leader><key> :call Ide.toggleTerminal()<cr>
```

Toggle terminal within the terminal window itself:
```vim
tnoremap <leader><key> <C-w>:call Ide.toggleTerminal()<cr>
```

## Disclaimer
This is a very basic and probably wont fit your needs. It's ongoing development.
