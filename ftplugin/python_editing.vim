" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1

autocmd InsertLeave,WinEnter * setlocal foldmethod=expr
autocmd InsertEnter,WinLeave * setlocal foldmethod=manual

map <buffer> <S-e> :w<CR>:!/usr/bin/env python % <CR>
map <buffer> gd /def <C-R><C-W><CR> 

set foldmethod=expr
set foldexpr=PythonFoldExpr(v:lnum)
set foldtext=PythonFoldText()
let b:indocstring = 0
let b:infuncdef = 0
let b:func_indent = -1

nnoremap <buffer> f za
nnoremap <buffer> F :call ToggleFold()<CR>
let b:folded = 1

function! ToggleFold()
    if( b:folded == 0 )
        exec "normal! zM"
        let b:folded = 1
    else
        exec "normal! zR"
        let b:folded = 0
    endif
endfunction

function! PythonFoldText()

    let size = 1 + v:foldend - v:foldstart
    if size < 10
        let size = " " . size
    endif
    if size < 100
        let size = " " . size
    endif
    if size < 1000
        let size = " " . size
    endif

    if match(getline(v:foldstart), '"""') >= 0
        let text = substitute(getline(v:foldstart), '"""', '', 'g' ) . ' '
    elseif match(getline(v:foldstart), "'''") >= 0
        let text = substitute(getline(v:foldstart), "'''", '', 'g' ) . ' '
    else
        let text = getline(v:foldstart)
    endif

    return size . ' lines:'. text . ' '

endfunction

function! PythonFoldExpr(lnum)

    if getline(a:lnum-1) =~ '^\(class\|def\)\s'
        let b:func_indent = indent(a:lnum-1)
        if getline(a:lnum-1) !~ '):$'
            let b:infuncdef = 1
        else
            return 'a1'
        endif

    elseif (b:infuncdef && getline(a:lnum-1) =~ '):$')
            let b:infuncdef = 0
            return 'a1'

    elseif (getline(a:lnum-1) =~ '"""' || getline(a:lnum-1) =~ "'''")
        if b:indocstring
            let b:indocstring = 0
        else
            let b:indocstring = 1
            return 'a1'
        endif

    elseif b:indocstring
        if (getline(a:lnum) =~ '"""' || getline(a:lnum) =~ "'''")
            return 's1'
        endif

    elseif (b:func_indent >= 0 && !b:indocstring)
        if indent(nextnonblank(a:lnum)) <= b:func_indent
            let b:func_indent = -1
            return 's1'
        endif
    endif

    return '='

endfunction

" In case folding breaks down
function! ReFold()
    set foldmethod=expr
    set foldexpr=0
    set foldnestmax=1
    set foldmethod=expr
    set foldexpr=PythonFoldExpr(v:lnum)
    set foldtext=PythonFoldText()
    let b:indocstring = 0
    let b:infuncdef = 0
    let b:func_indent = -1
    let b:folded = 1
    echo 
endfunction

