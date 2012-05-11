"=============================================================================
" FILE: fuel.vim
" Last Modified: 2012-05-11
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================
let s:save_cpo = &cpo
set cpo&vim

" Variables  "{{{
call unite#util#set_default('g:unite_source_fuel_ignore_pattern',
      \'^\%(/\|\a\+:/\)$\|\%(^\|/\)\.\.\?$\|empty$\|\~$\|\.\%(o|exe|dll|bak|sw[po]\)$')
"}}}
"
function! s:fuel_root()
  return finddir("fuel", ".;")
endfunction

let s:places = [
      \ {'name' : ''           , 'path' : '/'                       } ,
      \ {'name' : 'app'        , 'path' : '/app'                    } ,
      \ {'name' : 'controller' , 'path' : '/app/classes/controller' } ,
      \ {'name' : 'model'      , 'path' : '/app/classes/model'      } ,
      \ {'name' : 'view'       , 'path' : '/app/classes/view'       } ,
      \ {'name' : 'views'      , 'path' : '/app/views'              } ,
      \ {'name' : 'lang'       , 'path' : '/app/lang'               } ,
      \ {'name' : 'config'     , 'path' : '/app/config'             } ,
      \ {'name' : 'modules'    , 'path' : '/app/modules'            } ,
      \ {'name' : 'migrations' , 'path' : '/app/migrations'         } ,
      \ {'name' : 'tasks'      , 'path' : '/app/tasks'              } ,
      \ {'name' : 'vendor'     , 'path' : '/app/vendor'             } ,
      \ {'name' : 'public'     , 'path' : '/../public'              } ,
      \ {'name' : 'packages'   , 'path' : '/packages'               } ,
      \ {'name' : 'core'       , 'path' : '/core'                   } ,
      \ ]

let s:source = {}

function! s:source.gather_candidates(args, context)
  return s:create_sources(self.path)
endfunction

" fuel/command
"   history
"   [command] fuel

let s:source_command = {}

function! unite#sources#fuel#define()
  return map(s:places ,
        \   'extend(copy(s:source),
        \    extend(v:val, {"name": "fuel/" . v:val.name,
        \   "description": "candidates from history of " . v:val.name}))')
endfunction

function! s:create_sources(path)
  let root = s:fuel_root()
  if root == "" | return [] | end
  let files = map(split(globpath(root . a:path , '**') , '\n') , '{
        \ "name" : fnamemodify(v:val , ":t:r") ,
        \ "path" : v:val
        \ }')

  let list = []
  for f in files
    if isdirectory(f.path) | continue | endif

    if g:unite_source_fuel_ignore_pattern != '' &&
          \ f.path =~  string(g:unite_source_fuel_ignore_pattern)
        continue
    endif

    call add(list , {
          \ "abbr" : substitute(f.path , root . a:path . '/' , '' , ''),
          \ "word" : substitute(f.path , root . a:path . '/' , '' , ''),
          \ "kind" : "file" ,
          \ "action__path"      : f.path ,
          \ "action__directory" : fnamemodify(f.path , ':p:h:h') ,
          \ })
  endfor

  return list
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
