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

## Layouts, bars and widgets

This vim script is structured using layouts, bars (or sidebars) and widgets.
Layouts provide you with a virtual interface that you can switch to when using
tabs. A layout is generally indexed using the tab number using the result of
the `tabpagenr()` function. However, this script allows you to create arbitrary
virtual layouts. 

### Bars or sidebars
A layout has 4 sidebars sorted by position (left, bottom, top, right). 

### Widgets
Every bar might have one ore more widgets. Widgets are shared globally but
constructed individually for every layout's sidebar, giving full flexibility.
An example showing this functionality can be found in the `widget` folder.

## Basic usage

This is a very brief and incomplete usage instroduction. I will update it
whenever possible.

Toggling a bar would be as easy as calling the command `:IdeToggleBar
<position>`, where position could either be `left`, `bottom`, `top,` or
`right`.

```vim
nnoremap <leader>h :IdeToggleBar left<cr>
nnoremap <leader>j :IdeToggleBar bottom<cr>
nnoremap <leader>l :IdeToggleBar right<cr>
```

### Widgets
Widgets are loaded manually to avoid too much processing.

```vim
call ide#loadwidget('terminal_unique')
call ide#loadwidget('terminal_shared')
```

Once a widget is loaded it can be attached to a specific layout.

```vim
call g:Ide.addWidget(1, 'bottom', 'terminal_unique')
```

It is also possible to attach a specific widget to all virtual layouts by
specifying `-1` as layoutid

```vim
call g:Ide.addWidget(-1, 'bottom', 'terminal_shared')
```

## Disclaimer
This script is for personal use, and it's still early development phase. I will
add more information as I continue to make progress.
