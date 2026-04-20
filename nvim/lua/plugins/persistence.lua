return {
  'folke/persistence.nvim',
  event = 'BufReadPre',
  opts = {
    options = vim.opt.sessionoptions:get(),
    -- Don't auto-restore — let user restore explicitly or via workspaces
    autostart = false,
  },
  keys = {
    { '<leader>qs', function() require('persistence').load() end, desc = 'Restore session' },
    { '<leader>ql', function() require('persistence').load({ last = true }) end, desc = 'Restore last session' },
    { '<leader>qd', function() require('persistence').stop() end, desc = "Don't save session" },
  },
}
