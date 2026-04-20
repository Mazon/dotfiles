return {
  'natecraddock/workspaces.nvim',
  cmd = { 'WorkspacesOpen', 'Workspaces' },
  keys = {
    { '<leader>wo', '<cmd>WorkspacesOpen<CR>', desc = 'Open workspaces' },
  },
  opts = {
    path = vim.fn.stdpath 'data' .. '/workspaces',
  },
}
