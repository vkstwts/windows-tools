set number
syntax on
set background=dark

au BufReadPost *.xconf set syntax=xml
au BufReadPost *.rbInfo set syntax=properties

map <F9> :w<CR>:!python %<CR>
map <F8> :w<CR>:!svn ci %<CR>
map <F7> :w<CR>:!svn diff %<CR>
map <F6> :w<CR>:!svn log %<CR>


if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
    set fileencodings=utf-8,latin1
endif
if v:version >= 700
    "The following are a bit slow
    "for me to enable by default
    "set cursorline   "highlight current line
    "set cursorcolumn "highlight current column
endif
"don't be backwards compatible with silly vi options
set nocompatible
"allow backspacing over everything in insert mode
set bs=2
set viminfo='20,\"50    " read/write a .viminfo file, don't store more
                        " than 50 lines of registers
set history=50          " keep 50 lines of command line history
"Always show cursor position
set ruler
if has("autocmd")
  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost *
  \ if line("'\"") > 0 && line ("'\"") <= line("$") |
  \   exe "normal g'\"" |
  \ endif
endif
"This is necessary to allow pasting from outside vim. It turns off auto stuff.
"You can tell you are in paste mode when the ruler is not visible
set pastetoggle=<F2>
set autoindent
set smartindent
"Usually annoys me
set nowrap
"I always work on dark terminals
set background=dark
"Make the completion menus readable
highlight Pmenu ctermfg=0 ctermbg=3
highlight PmenuSel ctermfg=0 ctermbg=7
"The following should be done automatically for the default colour scheme
"at least, but it is not in Vim 7.0.17 at least.
if &bg == "dark"
  highlight MatchParen ctermbg=darkblue guibg=blue
endif
"Syntax highlighting if appropriate
if &t_Co > 2 || has("gui_running")
    syntax on
    set hlsearch
    set incsearch "For fast terminals can highlight search string as you type
endif
"Usually I don't care about case
set ignorecase
"Only ignore case when we type lower case
set smartcase
if &diff
    "I'm only interested in diff colours
    syntax off
endif
"I hate noise
set visualbell
"Show menu with possible completions
set wildmenu
"Ignore these files when completing names and in Explorer
set wildignore=.svn,CVS,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif

"The rest deal with whitespace handling and
"mainly make sure hardtabs are never entered
"as their interpretation is too non standard in my experience
set softtabstop=4
" Note if you don't set expandtab, vi will automatically merge
" runs of more than tabstop spaces into hardtabs. Clever but
" not what I usually want.
set expandtab
set shiftwidth=4
set shiftround
set nojoinspaces

"flag problematic whitespace (trailing and spaces before tabs)
"Note you get the same by doing let c_space_errors=1 but
"this rule really applys to everything.
highlight RedundantSpaces term=standout ctermbg=red guibg=red
match RedundantSpaces /\s\+$\| \+\ze\t/ "\ze sets end of match so only spaces highlighted
"use :set list! to toggle visible whitespace on/off
set listchars=tab:>-,trail:.,extends:>

"allow deleting selection without updating the clipboard (yank buffer)
vnoremap x "_x
vnoremap X "_X

"<home> toggles between start of line and start of text
imap <khome> <home>
nmap <khome> <home>
inoremap <silent> <home> <C-O>:call Home()<CR>
nnoremap <silent> <home> :call Home()<CR>
function Home()
    let curcol = wincol()
    normal ^
    let newcol = wincol()
    if newcol == curcol
        normal 0
    endif
endfunction

"<end> goes to end of screen before end of line
imap <kend> <end>
nmap <kend> <end>
inoremap <silent> <end> <C-O>:call End()<CR>
nnoremap <silent> <end> :call End()<CR>
function End()
    let curcol = wincol()
    normal g$
    let newcol = wincol()
    if newcol == curcol
        normal $
    endif
    "The following is to work around issue for insert mode only.
    "normal g$ doesn't go to pos after last char when appropriate.
    "More details and patch here:
    "http://www.pixelbeat.org/patches/vim-7.0023-eol.diff
    if virtcol(".") == virtcol("$") - 1
        normal $
    endif
endfunction

"Ctrl-{up,down} to scroll.
"The following only works in gvim?
"Also vim doesn't have default C-{home,end} bindings?
if has("gui_running")
    nmap <C-up> <C-y>
    imap <C-up> <C-o><C-y>
    nmap <C-down> <C-e>
    imap <C-down> <C-o><C-e>
endif


