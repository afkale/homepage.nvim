# Vim Homepage Plugin
The Vim Homepage Plugin is a lightweight and customizable plugin designed to display a homepage in your Vim editor when no file is opened. It allows you to load a custom homepage from a file, center its content, and apply custom highlighting.

## Features
- Load a homepage from a file.
- Automatically center the content in the Vim window.
- Customizable colors and highlight groups.
- Automatically display the homepage when Vim starts with no file arguments.

## Instalation
### [Using vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'afkale/homepage.nvim'
```

### [Using packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use 'afkale/homepage.nvim'
```

### [Using lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
require("lazy").setup({
    { "afkale/homepage.nvim", opts = { } },
})
```
![image](./homepage.png)
