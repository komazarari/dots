"vi互換モードをオフ
set nocompatible
"色付けオン
syntax on
set background=dark
"ファイルタイププラグインを有効化
filetype indent plugin on
"タイプ途中のコマンドを画面最下行に表示
set showcmd
"行番号表示
set number
"全角スペース表示
highlight ZenkakuSpace ctermbg=white
match ZenkakuSpace /　/
"BSの働き
set backspace=indent,eol,start
"backupファイルの場所指定
"set backupdir=$HOME/vimbackup
"保存してなくてもファイル表示
set hidden
"日本語入力時のカーソルの色
if has('multi_byte_ime')||has('xim')
	highlight CursorlM guibg=Purple guifg=NONE
endif
"Explore初期ディレクトリ
set browsedir=current
"クリップボード使用
set clipboard=unnamed
"カレントディレクトリ自動切り替え
set autochdir
"C-Aで8進数の計算をさせない
set nrformats=octal
"ルーラー表示
set ruler
"移動コマンドで行頭に移動しない
set nostartofline
"全モードでマウス有効化
set mouse=a



""""""""""""""""""""""""""""""""""
"search
""""""""""""""""""""""""""""""""""
"検索語を強調表示
set hlsearch
"大文字と小文字を区別しない
set ignorecase
"大文字を混ぜた場合のみ区別
set smartcase
"インクリメンタルサーチ
set incsearch


""""""""""""""""""""""""""""""""""
"indent
""""""""""""""""""""""""""""""""""
"tabの代わりに空白
"set expandtab
"自動インデント
set autoindent
set smartindent
"タブの表示
set list
set listchars=tab:>-
"行頭の余白内でTabを打ち込むと'shiftwidth'だけインデント
set smarttab
"indent幅
set shiftwidth=4



""""""""""""""""""""""""""""""""""
"mapping
""""""""""""""""""""""""""""""""""
"baffer移動
nnoremap <C-N> <down>
nnoremap <C-P> <up>
"挿入モード時移動
inoremap <C-f> <right>
inoremap <C-b> <left>
inoremap <C-a> <home>
inoremap <C-e> <end>
"検索語の強調表示解除
nnoremap <C-L> :nohl<CR><C-L>
"dictionary
inoremap <TAB> <C-x><C-k>


""""""""""""""""""""""""""""""""""
"command
""""""""""""""""""""""""""""""""""
:command We :w|:e %


""""""""""""""""""""""""""""""""""
"status line
""""""""""""""""""""""""""""""""""
"ステータスラインを常に表示
set laststatus=2
"コマンドライン2行
set cmdheight=2
"ステータス行にファイルコード、改行コード表示
set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P
"入力モード時、ステータスラインのカラーを変更
augroup InsertHook
autocmd!
autocmd InsertEnter * highlight StatusLine guifg=#ccdc90 guibg=#2E4340
autocmd InsertLeave * highlight StatusLine guifg=#2E4340 guibg=#ccdc90
augroup END

