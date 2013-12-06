" foldcomments.vim - Fold all comments in a file.
" Author: Xavier Nayrac
" Version: 0.2.0

if exists('g:loaded_foldcomments') || &cp || v:version < 700
  finish
endif
let g:loaded_foldcomments = 1

command! FoldComments call foldcomments#fold()

