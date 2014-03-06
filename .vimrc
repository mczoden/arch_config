function VimrcVim()
    set nocompatible
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
    filetype plugin indent on
    set backspace=indent,eol,start
    set smarttab
    set smartindent
endfunction VimrcBasicIndent
call VimrcBasicIndent()

function VimrcTlist()
    set tags=tags;
    set autochdir

    let Tlist_Ctags_Cmd = '/usr/bin/ctags'
    let Tlist_Show_One_File = 1
    let Tlist_Exit_OnlyWindow = 1
    "let Tlist_Use_Right_Window = 1
    let Tlist_GainFocus_On_ToggleOpen = 1
    let Tlist_Close_On_Select = 1

    map <F2> :Tlist<CR>
endfunction VimrcTlist
call VimrcTlist()

function VimrcLookupFile()
    let g:LookupFile_TagExpr = '"./filenametags"'
endfunction VimrcLookupFile

function VimrcAutoCmd()
    if has("autocmd")
        au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    endif
endfunction VimrcAutoCmd
call VimrcAutoCmd()

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

function ColorDefault()
    call ColorGeneral()
endfunction ColorDefault

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
endfunction ColorMiromiro

function ColorDesert256()
    colorscheme desert256
    " set background=light
    hi Normal       ctermbg=NONE
    hi NonText      ctermbg=NONE
    " call ColorGeneral()
endfunction ColorDesert256

function ColorLucius()
    let g:lucius_style = 'dark'
    colorscheme lucius
endfunction ColorLucius

let g:Python3Syntax = 1

function VimrcColor()
    if ! has("gui_running") 
        set t_Co=256 
    endif 
    call ColorLucius()
endfunction VimrcColor
call VimrcColor()

function IndentKR()
    set cinoptions=:0,(0
    "set equalprg=indent\ --k-and-r-style\ --no-tabs\ --start-left-side-of-comments
endfunction IndentKR

function VimrcProgram()
    let file_ext_name = strpart(@%, strridx(@%, "."))
    if (file_ext_name == ".c" || file_ext_name == ".h" || file_ext_name == ".py")
        set textwidth=79
        set colorcolumn=79
        call IndentKR()
    endif
endfunction VimrcProgram

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
