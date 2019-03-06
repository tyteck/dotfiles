set nocompatible
let mapleader=","
"set digraph "once commented no more backspace problem with meta char
set laststatus=2

" stop creating backup with ~
set nobackup
set nowritebackup

scriptencoding utf-8
set encoding=utf-8
set fileencoding=utf-8
set autoindent
:fixdel " normally to remove meta char when you type backspace then another key

"Vundle
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" colorscheme Gruvbox
Plugin 'morhetz/gruvbox'

" Plugin for Clojure
Plugin 'guns/vim-clojure-static'
Plugin 'tpope/vim-fireplace'
Plugin 'kien/rainbow_parentheses.vim'

" Airline le plugin qui sert à afficher des infos ѕur la ligne en cours
" (insert ou pas notamment)
Plugin 'vim-airline/vim-airline'

" tabularise le plugin pour aligner/indenter
Plugin 'godlygeek/tabular'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" configuration de indent_guides
let indent_guides_enable_on_vim_startup=1

" coloration syntaxique
syntax on
"jeu de couleurs
colorscheme gruvbox
" on passe gruvbox en sombre (c'est mieux)
set bg=dark

autocmd BufRead *.c     set cindent
autocmd BufRead *.pl    set cindent
autocmd BufRead *.conf  set cindent
autocmd BufRead *.pm    set cindent
autocmd BufRead *.html  set syn=html
autocmd BufRead *.php   set cindent
autocmd BufRead *.inc   set cindent
autocmd BufRead *.inc   set syn=php
autocmd BufRead *.tpl.php   set syn=php
autocmd BufRead *.sql   set syn=mysql

"affiche la position du curseur sur la ligne
set ruler

"avec coloration des mots recherches
set hlsearch

"no redraw during macros execution
set nolz

"cense corriger le backspace ...
set backspace=indent,eol,start "Allow backspacing over everything in insert mode

"match brace
set showmatch
set mat=4
set mps=(:),{:},[:],<:>

"format du fichier
set fileformats=unix,dos

"tabulation
set shiftwidth=4  " pour les touches >> et <<
set tabstop=4     " pour la touche Tab

nnoremap <F3> :bp<cr>
nnoremap <F4> :bn<cr>
nnoremap <F2> :NERDTreeToggle<cr>

" afficher les n° des lignes
"set nu

" 256 couleurs ?
if &term =~ "xterm"
	"256 color --
	let &t_Co=256
endif

if has("gui_running")
  if has("gui_gtk2")
    set guifont=Inconsolata\ 12
  elseif has("gui_win32")
    set guifont=Consolas:h11
  endif
endif

" vim airline smart-tab
let g:airline#extensions#tabline#enabled = 1


" NEOCOMPLCACHE, autocompletion
"Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
let g:neocomplcache_disable_auto_complete = 1

" Enable heavy features.
" Use camel case completion.
"let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
"let g:neocomplcache_enable_underbar_completion = 1

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplcache#undo_completion()
inoremap <expr><C-l>     neocomplcache#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
"inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  "return neocomplcache#smart_close_popup() . "\<CR>"
  " For no inserting <CR> key.
  return pumvisible() ? neocomplcache#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
"inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : <SID>check_back_space() ? "\<TAB>" : "\<C-x>\<C-u>"
        function! s:check_back_space()"{{{
        let col = col('.') - 1
        return !col || getline('.')[col - 1] =~ '\s'
        endfunction"}}

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" FREDT - normally disable auto comment on next line
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Enable heavy omni completion.
if !exists('g:neocomplcache_omni_patterns')
  let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplcache_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplcache_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplcache_omni_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
