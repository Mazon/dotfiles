return {
  'NickvanDyke/opencode.nvim',
  opts = {},
  keys = {
    { '<leader>ot', function() require('opencode').toggle() end, desc = 'Toggle opencode' },
    { '<leader>oA', function() require('opencode').ask() end, desc = 'Ask' },
    { '<leader>oa', function() require('opencode').ask('@this: ') end, desc = 'Ask about this', mode = { 'n', 'v' } },
    { '<leader>o+', function() require('opencode').append_prompt('@buffer') end, desc = 'Add buffer/selection to prompt', mode = { 'n', 'v' } },
    { '<leader>on', function() require('opencode').command('session_new') end, desc = 'New session' },
    { '<leader>oy', function() require('opencode').command('messages_copy') end, desc = 'Copy last response' },
    { '<S-C-u>', function() require('opencode').command('messages_half_page_up') end, desc = 'Messages half page up' },
    { '<S-C-d>', function() require('opencode').command('messages_half_page_down') end, desc = 'Messages half page down' },
    { '<leader>os', function() require('opencode').select() end, desc = 'Select prompt', mode = { 'n', 'v' } },
    { '<leader>oe', function() require('opencode').prompt('Explain @cursor and its context') end, desc = 'Explain this code' },
  },
  init = function()
    vim.g.opencode_opts = {
      on_submit = function()
        if vim.env.TMUX then
          vim.fn.system('tmux select-pane -t :.+')
        end
      end,
    }
  end,
}
