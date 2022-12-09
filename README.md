# ide.vim

IDE is a set of VIM scripts to help organize windows while developing software.

## Installation

Download the code and then use `packadd` to enable the plugin

```vim
packadd ide
if exists('Ide')
  " do remapping
endif
```

## Ide

The Ide class is the base class of the entire plugin. It acts as a controller between layouts and everything within it.

```c++
// Initializes a layout and returns an object of type 'IdeLayout'
// It wraps around the IdeLayouts.get() function to perform the logic
int Ide::getLayout(int layoutid)
```

## Layouts

Every layout is virtually mapped to the current `tabpagenr` value. Therefore, it is possible to have virtually any number of layouts for every tab opened.

Here is a list of functions for the Layouts code:

```c++
// Initializes a layout or returns an existing instance
Layout Layouts::get(int layoutid)
```

The `Layout` class offers the following methods:

```c++
// Constructs and initializes a Layout object
Layout Layout::new(int layoutid)
```

## Layouts, panel, bars and widgets

This vim script is structured using layouts, bars (or sidebars) and widgets.
Layouts provide you with a virtual interface that you can switch to when using
tabs. A layout is generally indexed using the tab number using the result of
the `tabpagenr()` function. However, this script allows you to create arbitrary
virtual layouts.

### Bars or sidebars
A layout is composed of a panel, two sidebars and widgets.

### Panel
The panel is the component used for displaying logs or running terminal commands
A panel can be aligned either by `left`, `right`, `center` or `justify`.

### Widgets
A bar and the panel might have one ore more widgets plugged in. 
Widgets are shared globally but constructed individually 
for every layout, giving full flexibility.
An example showing this functionality can be found in the `widget` folder.

## Layout Configuration

A layout has a configuration which can be setup in your .vimrc file.
If no configuration is passed in, a default configuration is created using
default parameters.

```vim
let cfg = g:IdeLayoutConfig.new()
call cfg.setPanelAlignment("right")   " Align panel to the right (default)
call cfg.setPanelVisibility(0)        " Hide panel (default)

call cfg.setLeftBarVisibility(0)      " Hide left sidebar (default)
call cfg.setRightBarVisibility(1)     " Show right sidebar

" Setting the config for the current layout
call g:Ide.getLayout().setConfig(cfg)

" Force layout to be redrawn
call g:Ide.redraw()
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

## Screenshot

Simple use for a c program with object disassembly + readelf

![C Ide Example](/screenshot/c.png)

## API

### Makefile functions

The `makefile` class is a collection of function for handling Makefile related operations, which is very useful when working with C and C++ projects. CMake and AutoMake will be supported in the future as well.

```vim
makefile#lookup(cwd)            " Traverses the parent dirs (up to 3) for a Makefile
makefile#parse(makefile)        " Parses all the useful info into an object
makefile#getvar(makefile, name) " Parses a single variable
makefile#buildcmd(target, vars, flags)
  " This is useful for generating the actual payload for the Makefile wrapper
makefile#runcmd(makefile, target, vars)
  " Runs a specific target within the makefile using the Makefile wrapper
makefile#readcmd(makefile, target, vars)
  " Same as above, it reads the output directly inside the buffer instead
```

## Disclaimer
This script is for personal use, and it's still early development phase. I will
add more information as I continue to make progress.

## v2.0
New version under development, this file will update with more information.
