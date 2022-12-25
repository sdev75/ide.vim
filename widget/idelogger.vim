" IDE logger is a wrapper around the IDE.logger object
" It is used for showing logs around the IDE layout
let s:bufname = "ide_logger"
let s:widget = g:IdeWidget.new('idelogger')

fun! s:widget.constructor(widget, payload)
endfun

fun! s:widget.update(widget, payload)
endfun

fun! s:widget.destructor(widget, payload)
endfun

call g:IdeWidgets.register(s:widget)
