# Lua Folder Index

This document provides a comprehensive index of all files in the `lua` folder of your Neovim configuration.

## Root Level Files

### `init.lua` (1.1KB, 35 lines)
- Main entry point for the Lua configuration
- Loads core modules and initializes the configuration

### `keymappings.lua` (9.6KB, 201 lines)
- Contains all key mappings and shortcuts
- Defines custom key bindings for various plugins and functions

## Core Module (`core/`)

### `init.lua` (189B, 7 lines)
- Core module initialization
- Sets up basic core functionality

### `autocmds.lua` (13KB, 391 lines)
- Auto-commands and event handlers
- Defines behavior for various file types and events

### `options.lua` (662B, 31 lines)
- Neovim options and settings
- Global configuration options

### `util.lua` (3.7KB, 116 lines)
- Utility functions and helpers
- Common functions used across the configuration

### `startup_messages.lua` (4.0KB, 106 lines)
- Startup messages and notifications
- Welcome screen and initialization messages

### `java_func.lua` (897B, 38 lines)
- Java-specific functions
- Java development utilities

### `go_func.lua` (1.1KB, 35 lines)
- Go language functions
- Go development utilities

### `git_format.lua` (4.3KB, 139 lines)
- Git formatting functions
- Git-related utilities and formatting

### `fzf_func.lua` (1.5KB, 34 lines)
- FZF (Fuzzy Finder) functions
- Search and file finding utilities

### `floatterm_func.lua` (703B, 22 lines)
- Floating terminal functions
- Terminal management utilities

## LSP Module (`lsp/`)

### `init.lua` (25B, 2 lines)
- LSP module initialization
- Basic LSP setup

### `common.lua` (2.3KB, 51 lines)
- Common LSP functions and configurations
- Shared LSP utilities

### `lspconfig.lua` (2.8KB, 121 lines)
- Language Server Protocol configurations
- Individual language server setups (Dart, Go, Python, etc.)

## Configuration Module (`config/`)

### `init.lua` (28B, 2 lines)
- Configuration module initialization
- Basic config setup

### `nvim-dap.lua` (15KB, 452 lines)
- Debug Adapter Protocol configuration
- Debugging setup and configurations

### `nvim-cmp.lua` (1.6KB, 48 lines)
- Completion configuration
- Code completion settings

### `telescope.lua` (1.9KB, 62 lines)
- Telescope fuzzy finder configuration
- Search and navigation settings

### `nvim-treesitter.lua` (598B, 16 lines)
- Tree-sitter configuration
- Syntax highlighting and parsing

### `nvim-tree.lua` (276B, 16 lines)
- File tree configuration
- File explorer settings

### `gruvbox.lua` (746B, 28 lines)
- Gruvbox theme configuration
- Color scheme settings

### `tokyonight.lua` (816B, 34 lines)
- Tokyo Night theme configuration
- Alternative color scheme

### `monokai.lua` (229B, 5 lines)
- Monokai theme configuration
- Another color scheme option

### `wilder.lua` (362B, 13 lines)
- Wilder command line configuration
- Enhanced command line interface

## Plugins Module (`plugins/`)

### `init.lua` (1.2KB, 37 lines)
- Plugin initialization
- Plugin manager setup

### `nvim-java-profiles.lua` (16KB, 474 lines)
- Java development profiles
- Comprehensive Java development setup

### `nvim-noti.lua` (13KB, 262 lines)
- Notification system
- Enhanced notification handling

### `nvim-debug-enhanced.lua` (3.3KB, 95 lines)
- Enhanced debugging features
- Advanced debugging utilities

### `nvim-codeium.lua` (1.5KB, 17 lines)
- Codeium AI completion
- AI-powered code completion

### `nvim-supermaven.lua` (953B, 24 lines)
- Supermaven AI assistant
- AI coding assistant integration

### `nvim-ai.lua` (896B, 21 lines)
- General AI integration
- AI-powered features

### `nvim-telescope-history.lua` (469B, 16 lines)
- Telescope history
- Search history management

### `nvim-codesnap.lua` (444B, 14 lines)
- Code screenshot utility
- Code sharing and documentation

### `nvim-cmdline.lua` (774B, 30 lines)
- Command line enhancements
- Improved command line interface

### `nvim-common.lua` (461B, 20 lines)
- Common plugin utilities
- Shared plugin functions

### `nvim-telescope.lua` (415B, 16 lines)
- Telescope configuration
- Fuzzy finder setup

### `nvim-outline.lua` (164B, 9 lines)
- Code outline
- Symbol tree and navigation

### `nvim-lualine.lua` (166B, 9 lines)
- Status line configuration
- Bottom status bar

### `nvim-airline.lua` (46B, 4 lines)
- Airline status line
- Alternative status line

### `nvim-treesitter.lua` (205B, 6 lines)
- Tree-sitter plugin
- Syntax parsing

### `nvim-trouble.lua` (157B, 9 lines)
- Trouble diagnostics
- Diagnostic display

### `nvim-which-key.lua` (108B, 7 lines)
- Which-key configuration
- Key binding hints

### `nvim-wilder.lua` (91B, 5 lines)
- Wilder command line
- Enhanced command line

### `nvim-gruvbox.lua` (110B, 6 lines)
- Gruvbox theme plugin
- Color scheme

### `nvim-dap.lua` (96B, 5 lines)
- Debug adapter plugin
- Debugging support

### `nvim-nerdtree.lua` (35B, 4 lines)
- NERDTree file explorer
- File tree navigation

### `nvim-tig.lua` (77B, 5 lines)
- Tig git browser
- Git repository browser

### `nvim-fzf.lua` (49B, 5 lines)
- FZF integration
- Fuzzy finder

### `nvim-oil.lua` (160B, 9 lines)
- Oil file manager
- File management

### `nvim-planuml.lua` (78B, 5 lines)
- PlantUML support
- UML diagram support

### `nvim-detect-language.lua` (47B, 4 lines)
- Language detection
- File type detection

### `nvim-snip.lua` (298B, 14 lines)
- Snippet management
- Code snippets

### `nvim-theme.lua` (114B, 6 lines)
- Theme management
- Color scheme management

### `nvim-git.lua` (65B, 5 lines)
- Git integration
- Version control

### `nvim-go.lua` (28B, 4 lines)
- Go language support
- Go development

### `nvim-lsp.lua` (210B, 12 lines)
- LSP integration
- Language server support

### `nvim-rootter.lua` (114B, 7 lines)
- Root directory detection
- Project root finding

### `nvim-floaterm.lua` (37B, 4 lines)
- Floating terminal
- Terminal management

### `nvim-mason.lua` (562B, 26 lines)
- Mason package manager
- LSP and DAP installer

## Personal Module (`me/`)

### `util.lua` (14KB, 493 lines)
- Personal utility functions
- Custom helper functions and utilities

## Summary

**Total Files:** 47 files
**Total Size:** Approximately 120KB+ of Lua code
**Main Categories:**
- Core functionality (10 files)
- LSP configuration (3 files)
- Plugin configurations (30 files)
- Theme configurations (4 files)
- Personal utilities (1 file)

This configuration provides a comprehensive Neovim setup with support for:
- Multiple programming languages (Java, Go, Python, TypeScript, etc.)
- AI-powered coding assistance
- Advanced debugging capabilities
- Multiple themes and UI enhancements
- File management and navigation
- Git integration
- LSP support for various languages 