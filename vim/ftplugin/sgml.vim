" Vim filetype plugin file
" Language:		SGML (DocBook)
" Maintainer:	Ondrej Jomb�k <nepto AT platon.sk>
" License:		GNU GPL
" Version:		$Platon: vimconfig/vim/ftplugin/sgml.vim,v 1.5 2003-11-03 08:20:21 rajo Exp $


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
	finish
endif
let b:did_ftplugin = 1

" Set window width to 80
setlocal tw=78
setlocal autoindent


let b:input_method = "iso8859-2"

" turn on IMAP() input method
call UseDiacritics()

" Modeline {{{
" vim:set ts=4:
" vim600:fdm=marker fdl=0 fdc=3 vb t_vb=:
" }}}

