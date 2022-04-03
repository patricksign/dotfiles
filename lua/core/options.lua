-------------------------------------------------------------
-- General Neovim settings and configuration
-----------------------------------------------------------

local util = require("core.util")
local term = require("core.floatterm_func")
local golang = require("core.go_func")
local java = require("core.java_func")
local f = require("core.fzf_func")

f.config()

util.baseSetting()
util.disableProviderSupport()
util.backup()
util.unloadUnuseStuff()

term.baseConfig()

golang.golangHighlight()
golang.golangBuild()

java.JavaHighlight()
java.JavaBuild()
java.JavaSyntax()
-- java.JavaDetect()


-- f.searchFzfCommand()
-- f.findFileFromCurrentDirFzf()
