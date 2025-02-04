# iex.nvim

Interact with a IEx terminal inside neovim for a better experience! 

## Features

- Open an IEx terminal inside nvim.
- Send commands to the IEx terminal from your current buffer.

## How to use

Start with

```
:IEx toggle
```

Then, you can enter visual mode and send code to IEx with `<space>ex`.

## Goals

The main goal of this project is to improve the rough edges I have encountered
using IEx:

- Multiline editing
- History navigation

The way I will try to solve these problems is by having a buffer that acts as
the IEx interface, communicating bidirectionally with an actual IEx running in a
vim terminal. This means that the plugins has to:

- Show the IEx prompt and results of executing commands in the iex.nvim buffer.
- Make the IEx history searchable with fzf. The buffer may not have all of the
  history as it can be persisted over sessions.
