# arachne.nvim

A very minimal, notetaking system for neovim.

## TL;DR

Check out this [scuffed video](https://asciinema.org/a/523779) if you want to see it in action (asciinema might have some trouble with the telescope dialog window :) ).

A plugin that allows you to quickly capture notes, all the while not locking you into a system so that you can easily combine it with other tools.

The notes are in the markdown format, but I might add options for other formats if there is any interest.

You can "tag" your notes to find them easier/group them. Those tags are part of the filename To follow the low-tech philosophy. This allows you to use any of the tools you would usually use to find files.

A bit further down you will find an example on how to use Telescope.nvim to fuzzy find your notes or search in them.

An example note file might be named like this:

`2022-09-25--long-term-storage__public_thoughts.md`

"long-term-storage" is derived from the title you would provide, while public and thoughts are the tags.

## Usage

### Install

You can use the plugin manager of you choice, here is an example using packer.nvim:

```lua
use { 'oem/arachne.nvim' }
```

### Configure

There is not much to configure right now, in fact you can currently only configure the directory of your notes:

```lua
use { 'oem/arachne.nvim', config = function() require('arachne').setup { notes_directory = '/home/moi/zettelkasten' } }
```

Here is my setup, including a keybindining to create new notes:

```lua
use {
    "oem/arachne.nvim",
        config = function()
            require('arachne').setup {notes_directory = "/home/oem/sync/notes"}
    end,
        setup = function()
            vim.keymap.set('n', '<leader>nn',
                    function() return require('arachne').new() end)
            end
}
```

And here is an example on how to use telescope to have a very powerful search/retrieve system for your notes (this assumes your notes live in `~/notes`):

```lua
local M = {}

M.find_notes = function()
    require('telescope.builtin').find_files {
        prompt_title = '<notes::files>',
        cwd = '~/notes'
    }
end

M.search_notes = function()
    require('telescope.builtin').live_grep {
        prompt_title = '<notes::search>',
        cwd = '~/notes'
    }
end

return M
```

Keybind those two functions and you have a pretty powerful note retrieval system!

You can find a working example in my [dotfiles](https://github.com/oem/dotfiles/blob/main/neovim/.config/nvim/lua/config/telescope_setup.lua).

## Inspiration

The low-tech philosophy is loosely inspired by [denote.el](https://github.com/protesilaos/denote) and more generally by the unix philosophy of minimal and modular tools.
