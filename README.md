##  Guide install

Install neovim >=0.9

### lua

1. brew install fzf
2. brew install the_silver_searcher
3. brew install pyright
4. brew install neovim
5. brew install lazygit
6. install lazy vim: `https://www.lazyvim.org/installation`
7. brew install lua-language-server
8. install lua 5.1: `https://www.lua.org/ftp`
9. brew install ltex-ls
10. brew install typescript-language-server
11. Install `goimports` for auto format go source and import on thefly
- Open terminal and run:
  + `go install golang.org/x/tools/cmd/goimports@latest`
  + `go get golang.org/x/tools/gopls@latest`
12. Clone this repo, copy all file at folder `dotfile` to
   + `$HOME/.config/nvim/`
13. install new plugin if any: `lua/plugins/init.lua`
14. config new language server for language development:
   + `lua/lsp/lspconfig.lua`:
15. Install tig explorer
  - brew install autoconf automake libtool
  - clone repor install tig `https://jonas.github.io/tig/INSTALL.html`:
  - brew install tig
  - brew install pkg-config
  - make configure
  - ./configure
  - make
  - make install
Error:
```
    INSTALL install: chmod 755 /usr/local/bin: Operation not permitted
    src/tig -> /usr/local/bin
    install: /usr/local/bin/tig: Permission denied
    make: [install] Error 71
```
Resolved: `sudo make install`

### Coc
1. brew install neovim
2. Download plug.vim and put it in the "autoload" directory: `https://github.com/junegunn/vim-plug`
```
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```
3. brew install lazygit
4. brew install fzf
5. brew install the_silver_searcher
6. install nodejs >= 14.0 and install yarn: npm install yarn -g
7. Clone this repo, copy all file at folder `dotfile` to `$HOME/.config/nvim/`
8. Open `init.vim` at `$HOME/.config/nvim/init.vim`, install Plugin by command: `:PlugInstall`
9. Install coc by yarn, go to `$HOME/.vim/plugged/coc.nvim` and type at command: `yarn install` for install package of coc-settings
10. Install coc-setting dependency

- Open: `$HOME/.config/nvim/init.vim` by nvim and run bellow command: `:CocInstall coc-json coc-tsserver coc-go`
- Open `init.vim`, change `let g:coc_config_home = '/Users/nartvt/.config/nvim'` => your init.vim path

11. Install `goimports` for auto format go source and import on thefly

- Open terminal and run:
  + `go install golang.org/x/tools/cmd/goimports@latest`
  + `go get golang.org/x/tools/gopls@latest`

- OR open `init.vim` and run `:GoInstallBinaries`

12. open .bashrc OR .zshrc, put export bellow :
    `export PATH="$PATH:$HOME/go/bin"`

13. Error if present at vim open file

```
[coc.nvim]: dyld[11689]: Library not loaded: '/opt/homebrew/opt/icu4c/lib/libicudata.70.dylib'
  Referenced from: '/opt/homebrew/Cellar/boost/1.79.0_1/lib/libboost_regex-mt.dylib'
  Reason: tried: '/opt/homebrew/opt/icu4c/lib/libicudata.70.dylib' (no such file), '/usr/local/lib/libicudata.70.dylib' (no such file), '/usr/lib/libicudata.70.dylib' (no such file), '/opt/homebrew/Cellar/icu4c/71.1/lib/libicudata.70.dylib' (no such fil
e), '/usr/local/lib/libicudata.70.dylib' (no such file), '/usr/lib/libicudata.70.dylib' (no such file)
Watchman:  /opt/homebrew/bin/watchman --no-pretty get-sockname returned with exit code=null, signal=SIGABRT, stderr= dyld[11689]: Library not loaded: '/opt/homebrew/opt/icu4c/lib/libicudata.70.dylib'
  Referenced from: '/opt/homebrew/Cellar/boost/1.79.0_1/lib/libboost_regex-mt.dylib'
  Reason: tried: '/opt/homebrew/opt/icu4c/lib/libicudata.70.dylib' (no such file), '/usr/local/lib/libicudata.70.dylib' (no such file), '/usr/lib/libicudata.70.dylib' (no such file), '/opt/homebrew/Cellar/icu4c/71.1/lib/libicudata.70.dylib' (no such fil
e), '/usr/local/lib/libicudata.70.dylib' (no such file), '/usr/lib/libicudata.70.dylib' (no such file)
Uncaught exception: /opt/homebrew/bin/watchman --no-pretty get-sockname returned with exit code=null, signal=SIGABRT, stderr= dyld[11689]: Library not loaded: '/opt/homebrew/opt/icu4c/lib/libicudata.70.dylib'
  Referenced from: '/opt/homebrew/Cellar/boost/1.79.0_1/lib/libboost_regex-mt.dylib'
  Reason: tried: '/opt/homebrew/opt/icu4c/lib/libicudata.70.dylib' (no such file), '/usr/local/lib/libicudata.70.dylib' (no such file), '/usr/lib/libicudata.70.dylib' (no such file), '/opt/homebrew/Cellar/icu4c/71.1/lib/libicudata.70.dylib' (no such fil
e), '/usr/local/lib/libicudata.70.dylib' (no such file), '/usr/lib/libicudata.70.dylib' (no such file)
```

How to resolved: add to .bashrc OR .zshrc as bellow

```
export PATH="/opt/homebrew/opt/icu4c/bin:$PATH"
export PATH="/opt/homebrew/opt/icu4c/sbin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/icu4c/lib"
export CPPFLAGS="-I/opt/homebrew/opt/icu4c/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/icu4c/lib/pkgconfig"
```

14. Install tig explorer

- brew install autoconf automake libtool
- clone repor install tig `https://jonas.github.io/tig/INSTALL.html`:
- brew install tig
- brew install pkg-config
- make configure
- ./configure
- make
- make install

Error:

```
    INSTALL install: chmod 755 /usr/local/bin: Operation not permitted
    src/tig -> /usr/local/bin
    install: /usr/local/bin/tig: Permission denied
    make: [install] Error 71
```

Resolved: `sudo make install`

15. Install language server for ruby development

    - gem install solargraph
    - Plug 'neoclide/coc-solargraph'
    - Plug 'vim-ruby/vim-ruby'
    - :CocInstall coc-solargraph

16. NestJs config

- :CocInstall coc-tsserver coc-eslint coc-json coc-prettier coc-css

17. Vue development

- :CocInstall @yaegassy/coc-volar-tools
- :CocInstall @yaegassy/coc-volar
- :CocInstall coc-prettier@1.1.17

18. plugins
- :CocInstall coc-json coc-tsserver coc-eslint coc-highlight  coc-ultisnips
- :CocUpdate
- :CocUpdateSync
