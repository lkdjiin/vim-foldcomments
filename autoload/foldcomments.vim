" Some definitions:
" - single comment line group: A continuous group of single line
"   commentaries. For example, in C langage:
"   // This is a continuous
"   // group of single line
"   // commentaries.
" - multiple comment line group: A group of lines within a three
"   parts comment. Example in C langage:
"   /*
"     This ia a group of lines
"     within a three parts
"     comment.
"   */

" Initialize the plugin.
function s:init()
  let s:multi_comment_state = 0
  let s:single_comment_state = 0
  let s:allow_multi_comment = 0
  let s:single_comment = '^\s*#'

  let s:marker_on = substitute(&commentstring, '%s', '{{{', '')
  let s:marker_off = substitute(&commentstring, '%s', '}}}', '')

  call s:init_by_language()
endfunction

" Initialize the plugin for the particular language of the file.
function s:init_by_language()
  if &filetype == 'ruby'
    let s:multi_comment_start = '^=begin'
    let s:multi_comment_end = '^=end'
    let s:allow_multi_comment = 1
  elseif &filetype == 'haskell'
    let s:single_comment = '^\s*--'
    let s:multi_comment_start = '^\s*{-'
    let s:multi_comment_end = '-}'
    let s:allow_multi_comment = 1
  elseif &filetype == 'java' || &filetype == 'c' || &filetype == 'javascript'
    let s:single_comment = '^\s*//'
    let s:multi_comment_start = '^\s*/\*'
    let s:multi_comment_end = '\*/'
    let s:allow_multi_comment = 1
  elseif &filetype == 'racket'
    let s:single_comment = '^\s*;'
    let s:multi_comment_start = '^\s*#|'
    let s:multi_comment_end = '|#'
    let s:allow_multi_comment = 1
  elseif &filetype == 'logo' || &filetype == 'scheme'
    let s:single_comment = '^\s*;'
  elseif &filetype == 'vim'
    let s:single_comment = '^\s*"'
  endif
endfunction

" Tell if a line is the begining of a multiple comment lines group.
"
" line - The String line to check.
"
" Returns boolean.
function s:is_begin_multi_comment(line)
  return s:allow_multi_comment &&
        \!s:multi_comment_state &&
        \a:line =~ s:multi_comment_start &&
        \a:line !~ s:multi_comment_end
endfunction

" Tell if a line is the end of a multiple comment lines group.
"
" line - The String line to check.
"
" Returns boolean.
function s:is_end_multi_comment(line)
  return s:multi_comment_state && a:line =~ s:multi_comment_end
endfunction

" Tell if a line is the begining of a single comment lines group.
"
" line - The String line to check.
" num  - The line number in the file.
"
" Returns boolean.
function s:is_begin_single_comment(line, num)
  return !s:single_comment_state &&
        \!s:multi_comment_state &&
        \a:line =~ s:single_comment &&
        \getline(a:num + 1) =~ s:single_comment
endfunction

" Tell if a line is the end of a single comment lines group.
"
" num  - The line number in the file.
"
" Returns boolean.
function s:is_end_single_comment(num)
  return s:single_comment_state &&
        \getline(a:num + 1) !~ s:single_comment
endfunction

" Add the start folding marker to a line.
"
" line - The String line to mark.
" num  - Line number in the file.
function s:add_start_marker(line, num)
  call setline(a:num, a:line.' '.s:marker_on)
endfunction

" Add the end folding marker to a line.
"
" line - The String line to mark.
" num  - Line number in the file.
function s:add_end_marker(line, num)
  call setline(a:num, a:line.' '.s:marker_off)
endfunction

" Mark the line as the begining of a multiple comment group folding. 
"
" line - The String line to process.
" num  - The line number in the file. 
function s:begin_multi_folding(line, num)
  let s:multi_comment_state = 1
  call s:add_start_marker(a:line, a:num)
endfunction

" Mark the line as the begining of a single comment group folding. 
"
" line - The String line to process.
" num  - The line number in the file. 
function s:begin_folding(line, num)
  let s:single_comment_state = 1
  call s:add_start_marker(a:line, a:num)
endfunction

" Mark the line as the end of a multiple comment group folding. 
"
" line - The String line to process.
" num  - The line number in the file. 
function s:end_multi_folding(line, num)
  call s:add_end_marker(a:line, a:num)
  let s:multi_comment_state = 0
endfunction

" Mark the line as the end of a single comment group folding. 
"
" line - The String line to process.
" num  - The line number in the file. 
function s:end_folding(line, num)
  call s:add_end_marker(a:line, a:num)
  let s:single_comment_state = 0
endfunction

" Fold all groups of comment in the file.
function! foldcomments#fold()
  call s:init()
  for line_num in range(1, line("$"))
    let a_line = getline(line_num)
    if s:is_begin_multi_comment(a_line)
      call s:begin_multi_folding(a_line, line_num)
    elseif s:is_end_multi_comment(a_line)
      call s:end_multi_folding(a_line, line_num)
    elseif s:is_begin_single_comment(a_line, line_num)
      call s:begin_folding(a_line, line_num)
    elseif s:is_end_single_comment(line_num)
      call s:end_folding(a_line, line_num)
    endif
  endfor
endfunction


