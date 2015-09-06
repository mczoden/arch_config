function VimrcVim()
    set nocompatible
    set shell=/bin/sh
endfunction VimrcVim
call VimrcVim()

function VimrcFunc()
    set history=400
    if exists("&autoread")
        set autoread
    endif
endfunction VimrcFunc
call VimrcFunc()

function VimrcBasicUI()
    set number
    set incsearch
    set hlsearch
    set ruler
    let g:netrw_liststyle=3

    set keywordprg=man\ -s\ 2,3
endfunction VimrcBasicUI
call VimrcBasicUI()

function VimrcAdvancedUI()
    set mouse=n
    set noerrorbells
    set vb t_vb=
endfunction VimrcAdvancedUI
call VimrcAdvancedUI()

function VimrcSyntax()
    syntax on
endfunction VimrcSyntax
call VimrcSyntax()

function VimrcBasicIndent()
    set backspace=indent,eol,start
    set smarttab
    set smartindent
endfunction VimrcBasicIndent
call VimrcBasicIndent()

function VimrcTlist()
    set tags=tags;
    set autochdir

    let g:Tlist_Ctags_Cmd = '/usr/bin/ctags'
    let g:Tlist_Show_One_File = 1
    let g:Tlist_Exit_OnlyWindow = 1
    "let g:Tlist_Use_Right_Window = 1
    let g:Tlist_GainFocus_On_ToggleOpen = 1
    let g:Tlist_Close_On_Select = 1

    map <F2> :Tlist<CR>
endfunction VimrcTlist
call VimrcTlist()

function VimrcLookupFile()
    let g:LookupFile_TagExpr = '"./filenametags"'
endfunction VimrcLookupFile

function VimrcAutoCmd()
    filetype plugin indent on

    augroup vimrcEx
        au!
        autocmd FileType text setlocal textwidth=78
        autocmd BufReadPost *
                    \ if line("'\"") > 1 && line("'\"") <= line("$") |
                    \   exe "normal! g`\"" |
                    \ endif
        autocmd BufRead,BufNewFile *
                    \ if &filetype == "c" || &filetype == "cpp" |
                    \   set cinoptions=:0 |
                    \ elseif &filetype == "lua" |
                    \   set shiftwidth=2 |
                    \   set tabstop=2 |
                    \ endif
    augroup END
endfunction VimrcAutoCmd
if has('autocmd')
    call VimrcAutoCmd()
else
    set autoindent
endif

function VimrcFileEncoding()
    set fencs=utf-8,GB18030,ucs-bom,default,latin1
endfunction VimrcFileEncoding
call VimrcFileEncoding()

function VimrcEditor()
    set shiftwidth=4
    set tabstop=4
    set expandtab
endfunction VimrcEditor
call VimrcEditor()

function ColorGeneral()
    hi ColorColumn  ctermbg=Gray
    hi LineNr       ctermfg=Gray
endfunction ColorGeneral

function ColorMiromiro()
    colorscheme miromiro

    hi LineNr       ctermfg=8
    hi Normal       ctermbg=NONE
    hi NonText      ctermbg=NONE
    hi Folded       ctermbg=NONE
    hi FoldColumn   ctermbg=NONE
    hi Pmenu        ctermfg=7       ctermbg=0
    hi PmenuSel     ctermfg=0       ctermbg=7

    hi DiffAdd      term=bold       ctermbg=0
    hi DiffChange   term=NONE       cterm=NONE      ctermbg=NONE
    hi DiffDelete   term=bold       ctermfg=NONE    ctermbg=NONE
    hi DiffText     term=NONE       cterm=reverse   ctermfg=3       ctermbg=NONE 

    hi Comment      cterm=italic    ctermfg=7
    hi ColorColumn  term=bold       ctermbg=8       guibg=8

    call ColorGeneral()
endfunction ColorMiromiro

function ColorDesert256()
    colorscheme desert256

    hi Normal       ctermbg=NONE
    hi NonText      ctermbg=NONE

    call ColorGeneral()
endfunction ColorDesert256

function ColorLucius()
    let g:lucius_style = 'dark'
    colorscheme lucius

    " hi Normal       ctermbg=NONE
    " hi NonText      ctermbg=NONE
endfunction ColorLucius

function VimrcColor()
    if ! has('gui_running')
        set t_Co=256
    endif

    let os = substitute(system('uname'), "\n", "", "")
    if os == "Darwin"
        call ColorLucius()
    else
        call ColorDesert256()
    endif
endfunction VimrcColor
call VimrcColor()

function Vimrc_MiniBufExplorer()
    let g:miniBufExplMapWindowNavVim = 1
    let g:miniBufExplMapWindowNavArrows = 1 
    let g:miniBufExplMapCTabSwitchBufs = 1 
    let g:miniBufExplModSelTarget = 1 
    map <F4> :MiniBufExplorer<CR>
endfunction
call Vimrc_MiniBufExplorer()

function OmniCompletion()
    set omnifunc=syntaxcomplete
endfunction OmniCompletion
call OmniCompletion()
