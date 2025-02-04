---@class IexTerm
--- An IEx terminal is associated to a buffer (via `bufnr`) where the user
--- writes Elixir code. This code is sent to the terminal buffer using
--- `channel_id`, and the terminal `window` state is stored. 
local IexTerm = {}
IexTerm.__index = IexTerm

--- Creates a new IEx terminal window associated to a buffer
---@param bufnr integer The number of the buffer associated to the IEx terminal.
---@return IexTerm
function IexTerm:new(bufnr)
  return setmetatable({
    bufnr = bufnr,
    window = {
      buf = -1,
      win = -1,
    },
    channel_id = 0,
  }, self)
end

--- @class CreateRightWindowOpts
--- Creates a new window and buffer for the terminal.
--- @param opts CreateRightWindowOpts
--- @field buf integer - Buffer handler for the editing code editor buffer.
--- @return table
function IexTerm:create_right_window(opts)
  opts = opts or {}

  -- Create or reuse buffer
  local buf = opts.buf
  if not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  end

  -- Open vertical split and set the buffer
  vim.cmd("vsplit")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.cmd("wincmd L")

  -- Configure the window
  vim.api.nvim_win_set_option(win, "number", false)
  vim.api.nvim_win_set_option(win, "relativenumber", false)

  self.window = { buf = buf, win = win }

  return self.window
end

--- Opens or closes the IEx terminal. Creates a terminal if it does not exists.
function IexTerm:toggle_iex()
  if vim.api.nvim_win_is_valid(self.window.win) then
    vim.api.nvim_win_hide(self.window.win)
    return
  end
  local curr_win = vim.api.nvim_get_current_win()
  self.window = self:create_right_window({ buf = self.window.buf })
  if vim.bo[self.window.buf].buftype ~= "terminal" then
    self.channel_id = vim.fn.termopen("iex", {
      on_exit = function()
        self.channel_id = 0 -- Reset channel_id when terminal exits
      end,
    })
  end

  vim.api.nvim_set_current_win(curr_win)
end

--- Sends a command to the IEx terminal from the current buffer.
--- @param cmd string
function IexTerm:send_command(cmd)
  if self.channel_id == 0 or not vim.api.nvim_buf_is_valid(self.window.buf) then
    print("Error: IEx terminal is not running.")
    return
  end

  cmd = string.gsub(cmd, "\n\n", "\n")
  cmd = string.gsub(cmd, "\n+$", "")

  vim.api.nvim_chan_send(self.channel_id, cmd .. "\n")
end

--- Kills the IEx terminal by closing the window and stopping the running job.
function IexTerm:kill()
  if not vim.api.nvim_buf_is_valid(self.window.buf) then
    return
  end
  if not vim.api.nvim_win_is_valid(self.window.win) then
    return
  end

  vim.api.nvim_win_close(self.window.win, true)
  vim.fn.jobstop(self.channel_id)
  self.channel_id = 0
end

return IexTerm
