if v:progname =~? "evim"
  finish
endif


filetype plugin on

"set term=xterm-color
"set term=dtterm

if &term == "screen"
"  if has("terminfo")
"     set t_Co=16
"     set t_AB=[%?%p1%{8}%<%t%p1%{40}%+%e%p1%{92}%+%;%dm
"     set t_AF=[%?%p1%{8}%<%t%p1%{30}%+%e%p1%{82}%+%;%dm
"  else
"     set t_Co=16
"     set t_Sf=[3%dm
"     set t_Sb=[4%dm
"  endif
else "cygwin, xterm, any others?
  if has("terminfo")
    set t_Co=256
    set t_Sf=[3%p1%dm
    set t_Sb=[4%p1%dm
  else
    set t_Co=8
    set t_Sf=[3%dm
    set t_Sb=[4%dm
  endif
endif

set nocompatible
set backspace=indent,eol,start
set autoindent		" always set autoindenting on
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set nobackup		" do not keep backups


" have syntax highlighting in terminals which can display colours:

if has('syntax') && (&t_Co > 2)
    syntax on
else
    echo "Not enablind syntax"

endif


"set autoindent		" indent same as previous line
set shiftwidth=4	" nr of spaces for indentstep
"set smartindent	" smart autoident for c programs
set tabstop=4		" show tabstop as 8
set smarttab		" use shiftwidth when inserting tab
set expandtab		" use spaces instead of tabs
set formatoptions-=tl
set hidden
set vb t_vb=            " turn off beeping


" Highlight spaces at the end of a line and spaces in front of tabs
let c_space_errors=1
let java_space_errors=1
let python_space_errors=1
let xml_space_errors=1

" Use 4 space for tab in C, C++ and PERL files
"autocmd FileType cpp,c,perl,pl set shiftwidth=4 expandtab


" have command-line completion <Tab> (for filenames, help topics, option names)
" first list the available options and complete the longest common part, then
" have further <Tab>s cycle through the possibilities:
set wildmode=list:longest,full


" in makefiles, don't expand tabs to spaces, since actual tab characters are
" needed, and have indentation at 8 chars to be sure that all indents are tabs
" (despite the mappings later):
"autocmd FileType make set noexpandtab shiftwidth=8

set background=dark
hi SpecialKey    guifg=RoyalBlue2
hi MoreMsg       guifg=Green 
hi Folded        ctermbg=4 guibg=Blue 
hi FoldColumn    ctermbg=7 
hi DiffAdd       guibg=Blue 
hi DiffChange    guibg=Magenta 
hi DiffDelete    guibg=Cyan 
hi Normal        guifg=Gray guibg=Black 
hi Cursor        guibg=White 
hi lCursor       guibg=White 
"hi Comment       guifg=Cyan 
"hi Comment       ctermfg=Cyan  ctermbg=Darkblue
hi Constant      guifg=Magenta 
hi Special       guifg=White guibg=Red  
hi Identifier    guifg=Cyan 
hi Statement     guifg=Yellow 
hi PreProc       guifg=RoyalBlue2
hi Type          guifg=Green 
hi Underlined    guifg=RoyalBlue2
hi Todo          guifg=Black

"hi Comment ctermfg=145 guifg=#afafaf
hi Comment ctermfg=149

" Don't load the MatchParen plugin
let loaded_matchparen = 1

set guioptions-=m	" get rid of the menu bar 
set go-=T		" get rid of the tool bar
set guifont=-misc-fixed-medium-r-normal-*-*-120-*-*-c-*-iso8859-1\ 9
"set guifont=Monospace\ 8

if has("autocmd")
  filetype plugin indent on
  autocmd FileType text setlocal textwidth=78
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

endif " has("autocmd")

" Custom status line display
set ls=2 " Always show status line
if has('statusline')
    " Status line detail:
    " %f		file path
    " %y		file type between braces (if defined)
    " %([%R%M]%)	read-only, modified and modifiable flags between braces
    " %{'!'[&ff=='default_file_format']}
    "			shows a '!' if the file format is not the platform
    "			default
    " %{'$'[!&list]}	shows a '*' if in list mode
    " %{'~'[&pm=='']}	shows a '~' if in patchmode
    " (%{synIDattr(synID(line('.'),col('.'),0),'name')})
    "			only for debug : display the current syntax item name
    " %=		right-align following items
    " #%n		buffer number
    " %l/%L,%c%V	line number, total number of lines, and column number
    function SetStatusLineStyle()
	if &stl == '' || &stl =~ 'synID'
	    let &stl="%f %y%([%R%M]%)%{'!'[&ff=='".&ff."']}%{'$'[!&list]}%{'~'[&pm=='']}%=#%n %l/%L,%c "
	else
	    let &stl="%f %y%([%R%M]%)%{'!'[&ff=='".&ff."']}%{'$'[!&list]} (%{synIDattr(synID(line('.'),col('.'),0),'name')})%=#%n %l/%L,%c "
	endif
    endfunc
    " Switch between the normal and vim-debug modes in the status line
    nmap _ds :call SetStatusLineStyle()<CR>
call SetStatusLineStyle()
    " Window title
    if has('title')
	set titlestring=%t%(\ [%R%M]%)
    endif
endif

if &term == "dtterm"
    set t_kb=
    fixdel
endif

:nnoremap <F12><Tab>      :syntax match Special "\t"<CR>
:inoremap <F12><Tab> <C-O>:syntax match Special "\t"<CR>
":nnoremap <F12><Tab>      :syntax match Special "\t\|([\t ]$)"<CR>
":inoremap <F12><Tab> <C-O>:syntax match Special "\t\|([\t ]$)"<CR>

":map <C-Right> echo "w"
":map <C-Left> echo "b"

" Fix xml end tags
" :%s/<\([^<>]\+\)>\([^<>]*\)<\/>/<\1>\2<\/\1>/g

set nocp
filetype plugin on

function! SuperCleverTab()
    if strpart(getline('.'), 0, col('.') - 1) =~ '^\s*$'
        return "\<Tab>"
    else
        "if &omnifunc != ''
        "    return "\<C-X>\<C-O>"
        "elseif &dictionary != ''
        if &dictionary != ''
            return "\<C-K>"
        else
            return "\<C-N>"
        endif
    endif
endfunction

"inoremap <Tab> <C-R>=SuperCleverTab()<cr>
inoremap � <C-N>

syntax match Tab /\t/
hi Tab gui=underline guifg=red ctermbg=red


:highlight ExtraWhitespace ctermbg=red guibg=red
:highlight ExtraWhitespace2 ctermbg=red guibg=red
":match ExtraWhitespace /\t\+/
":match ExtraWhitespace2 /[\t ]\+$/


:highlight LongLines ctermbg=darkgray guibg=Magenta
"match LongLines '\%>80v.\+'

if has("autocmd")
    if v:version > 701
        autocmd Syntax * call matchadd('ExtraWhitespace',  '\t\+')
        autocmd Syntax * call matchadd('ExtraWhitespace2', '[\t ]\+$')
        autocmd Syntax * call matchadd('LongLines', '\%>80v.\+')
    endif
endif

set pastetoggle=<F12>

:map <F10> :s/^/#/ge<CR>
:map <F9> :s/^#//ge<CR>