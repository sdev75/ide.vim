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
By default the IDE will draw the layout upon initialization. However, this might not always be the desired outcome. It's possible to disable the automatic drawing by setting the global variable `g:IdeAutoDraw` to 0.

An example below shows how to manually draw the IDE plugin with a shortcut:

```vim
" Disable auto initialization (the layout wont be drawn)
let g:IdeAutoDraw = 0

" Initialize the IDE (the layout will be drawn according to the settings)
nnoremap <leader>ii :call g:Ide.redraw()<cr>
```

### Init and shutdown callbacks

It's possible to customize the init and shutdown routine by adding your own callback. This is experimental and I might consider removing it.

```vim
call g:Ide.setCallback("shutdown",
      \  {payload -> execute('call g:Ide.logmsg(string(payload))','') })
```

## Ide

The Ide class is the base class of the entire plugin. It acts as a controller between layouts and everything within it.

```c++
// Initializes a layout and returns an object of type 'IdeLayout'
// It wraps around the IdeLayouts.get() function to perform the logic
int Ide::getLayout(int layoutid)
```

### Ide autocmd groups

Ide has a few user defined auto commands for events such as when starting VIM, leaving it and resize the VIM screen.

Here is a list of all the user autocommands defined in `plugin/ide.vim`:

```vim
au VimEnter     * do User onIdeInit
au VimLeavePre  * do User onIdeShutdown
au VimResized   * do User onIdeResize
```

There are also several `FileType` options for C and C++ files. These might be refactored later on with the support of more programming languages.

### IDE autoload functions (core functionality)

Ide autoload has a set of functions for loading up libraries, core files and setting up commands.

Here is the list of the major functions defined in `autoload/ide.vim`:

```c++
" Loads the core files necessary for starting up the Ide plugin
ide::initCoreFiles(void)

" Loads a library file located in the lib folder
" It executes a runtime command
ide::loadlib(string)

" Loads a widget in the same way loadlib loads a library
ide::loadwidget(string)
```

## IDE Logger

I decided to go for logging data using a class and writing the data to a buffer rather than using `echom`. This decision was made to improve flexibility and personal preference. It also allows the debugs to be displayed wherever I need.

By the default, there is no logging setup. Logging can be turned on by loading the logger library and assigning the `IdeLogger` object to the IDE instance.

Here's an example on how to do what I just said:
```vim
call ide#loadlib('ide/logger)
call g:Ide.setLogger(IdeLogger, 5)    " 5 referes to the verbosity level
```

Once the logger is assigned successfully, every log action is fired within the log object. This allows customization by creating a different Logger object and assign it to the IDE.

A Logger object must declare the following functions:

```vim
setVerbosityLevel(level)
add(type, level, prefix, msg)
info(level, prefix, msg)
warn(level, prefix, msg)
error(level, prefix, msg)
debug(level, prefix, msg)
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
let cfg.panelAlignment("right")   " Align panel to the right (default)
let cfg.panelVisibility(0)        " Hide panel (default)
let cfg.panelHeightPct(25)        " Sets the height percentage allocation

" Alternatively, all in one shot
let cfg = g:IdeLayoutConfig.new(#{
\ leftBarWidthPct: 20,
\ rightBarWidthPct: 30,
\ })

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
