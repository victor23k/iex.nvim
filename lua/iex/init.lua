--- Goals for this plugin:
--- 1. Enhance the experience of using IEx in a talk setting.
--- 2. Fast interaction with IEx in your coding sessions. 
--- 3. Be simple and highly configurable.

local M = {}

local IexFunctions = require("iex.builtin")

M.setup = function ()
  vim.api.nvim_create_user_command("IEx", function(opts)
    local command = opts.args
    IexFunctions[command]()
  end, {
    nargs = 1,
    complete = function (_, _)
      return vim.tbl_keys(IexFunctions)
    end
  })

  vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
    callback = function()
      vim.opt.number = false
      vim.opt.relativenumber = false
      vim.cmd "startinsert"
    end,
  })

  vim.keymap.set("v", "<space>ex", function ()
    local old_v = vim.fn.getreg('v')
    local old_v_type = vim.fn.getregtype('v')

    vim.cmd('normal! "vy')

    local text = vim.fn.getreg('v')

    vim.fn.setreg('v', old_v, old_v_type)

    print("Sending text: " .. text)
    IexFunctions.send(text)
  end, { silent = true })
end

M.IexFunctions = IexFunctions

return M
