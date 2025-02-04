local IexManager = require("iex.manager")
local IexTerm = require("iex.terminal")

--- @class IexFunctions
--- This module defines functions exposed to be used to configure your own
--- functionality.
local IexFunctions = {}

local function get_or_create_term(bufnr, clean)
  clean = clean or false
  if not IexManager.terminals[bufnr] or clean then
    IexManager.terminals[bufnr] = IexTerm:new(bufnr)
  end
  return IexManager.terminals[bufnr]
end


IexFunctions.toggle = function ()
  local bufnr = vim.api.nvim_get_current_buf()
  local iex_term = get_or_create_term(bufnr)
  iex_term:toggle_iex()
end

IexFunctions.kill = function ()
  local bufnr = vim.api.nvim_get_current_buf()
  local iex_term = IexManager.terminals[bufnr]
  if iex_term == nil then
    print("IEx terminal not running for this buffer")
    return
  end
  iex_term:kill()
  print("IEx terminal killed")
  IexManager.terminals[bufnr] = nil
end

IexFunctions.clean_start = function ()
  local bufnr = vim.api.nvim_get_current_buf()
  local iex_term = get_or_create_term(bufnr, true)
  iex_term:toggle_iex()
end

IexFunctions.send = function (text)
  local bufnr = vim.api.nvim_get_current_buf()
  local iex_term = IexManager.terminals[bufnr]
  if not iex_term then
    print("Error: No IEx terminal associated with this buffer.")
    return
  end
  print("Sending: " .. text)
  iex_term:send_command(text)
end

return IexFunctions
