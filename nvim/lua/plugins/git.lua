return {
  -- Gitsigns: gutter signs, hunk actions, blame
  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text_pos = 'eol',
      },
      word_diff = true,
    },
    keys = {
      { '<leader>ghs', function() require('gitsigns').stage_hunk() end, desc = 'Stage hunk', mode = { 'n', 'v' } },
      { '<leader>ghr', function() require('gitsigns').reset_hunk() end, desc = 'Reset hunk', mode = { 'n', 'v' } },
      { '<leader>ghu', function() require('gitsigns').undo_stage_hunk() end, desc = 'Undo stage hunk' },
      { '<leader>ghp', function() require('gitsigns').preview_hunk() end, desc = 'Preview hunk' },
      { '<leader>ghb', function() require('gitsigns').blame_line() end, desc = 'Blame line' },
      { '<leader>gB', function() require('gitsigns').blame_line { full = true } end, desc = 'Blame line (full)' },
      { '<leader>ghd', function() require('gitsigns').diffthis() end, desc = 'Diff this' },
      { ']h', function() require('gitsigns').nav_hunk('next') end, desc = 'Next hunk' },
      { '[h', function() require('gitsigns').nav_hunk('prev') end, desc = 'Previous hunk' },
    },
  },

  -- Neogit: Git workflow UI + Diffview: Diff viewer
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'folke/snacks.nvim',
    },
    keys = {
      { '<leader>gs', '<cmd>Neogit<CR>', desc = 'Neogit status' },
      { '<leader>gc', '<cmd>Neogit commit<CR>', desc = 'Neogit commit' },
      { '<leader>gp', '<cmd>Neogit pull<CR>', desc = 'Neogit pull' },
      { '<leader>gP', '<cmd>Neogit push<CR>', desc = 'Neogit push' },
      { '<leader>gd', '<cmd>DiffviewOpen<CR>', desc = 'Diff view' },
      { '<leader>gD', '<cmd>DiffviewFileHistory %<CR>', desc = 'Diff file history' },
      { '<leader>gC', '<cmd>DiffviewClose<CR>', desc = 'Diff view close' },
    },
  },
}
