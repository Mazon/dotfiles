return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = [[
███████╗███╗   ██╗ █████╗ ██╗  ██╗███████╗
██╔════╝████╗  ██║██╔══██╗██║ ██╔╝██╔════╝
█████╗  ██╔██╗ ██║███████║█████╔╝ █████╗
██╔══╝  ██║╚██╗██║██╔══██║██╔═██╗ ██╔══╝
███████╗██║ ╚████║██║  ██║██║  ██╗███████╗
╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝]],
      },
    },
    input = { enabled = true },
    picker = {
      enabled = true,
      preview = false,
      sources = {
        files = { hidden = true },
      },
      win = {
        input = {
          keys = {
            ['<Tab>'] = { 'list_down', mode = { 'i', 'n' } },
            ['<S-Tab>'] = { 'list_up', mode = { 'i', 'n' } },
          },
        },
        list = {
          keys = {
            ['<Tab>'] = { 'list_down', mode = { 'n', 'x' } },
            ['<S-Tab>'] = { 'list_up', mode = { 'n', 'x' } },
          },
        },
      },
    },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    -- find
    { '<leader>sh', function() Snacks.picker.help() end, desc = '[s]earch [h]elp' },
    { '<leader>sk', function() Snacks.picker.keymaps() end, desc = '[s]earch [k]eymaps' },
    { '<leader>sf', function() Snacks.picker.files() end, desc = '[s]earch [f]iles' },
    { '<leader>ss', function() Snacks.picker.pickers() end, desc = '[s]earch [s]elect Picker' },
    { '<leader>sw', function() Snacks.picker.grep_word() end, desc = '[s]earch current [w]ord', mode = { 'n', 'x' } },
    { '<leader>sg', function() Snacks.picker.grep() end, desc = '[s]earch by [g]rep' },
    { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = '[s]earch [d]iagnostics' },
    { '<leader>sr', function() Snacks.picker.resume() end, desc = '[s]earch [r]esume' },
    { '<leader>s.', function() Snacks.picker.recent() end, desc = '[s]earch Recent Files ("." for repeat)' },
    { '<leader>sl', function() Snacks.picker.lsp_symbols() end, desc = '[s]earch [l]sp Symbols' },
    { '<leader><leader>', function() Snacks.picker.buffers() end, desc = '[ ] Find existing buffers' },
    { '<leader>gb', function() Snacks.picker.git_branches() end, desc = 'Git [b]ranches' },
    { '<leader>gl', function() Snacks.picker.git_log() end, desc = 'Git [l]og' },
    { '<leader>gL', function() Snacks.picker.git_log_file() end, desc = 'Git file [L]og' },
    { '<leader>/', function() Snacks.picker.lines() end, desc = '[/] Fuzzily search in current buffer' },
    { '<leader>s/', function() Snacks.picker.grep_buffers() end, desc = '[s]earch [/] in Open Files' },
    { '<leader>sn', function() Snacks.picker.files { cwd = vim.fn.stdpath 'config' } end, desc = '[s]earch [n]eovim files' },
    -- notifications
    { '<leader>sN', function() Snacks.picker.notifications() end, desc = '[s]earch [N]otifications' },
    -- terminal
    { '<leader>tt', function() Snacks.terminal() end, desc = 'Toggle terminal' },
    -- words navigation
    { ']w', function() Snacks.words.jump(vim.v.count1) end, desc = 'Next reference' },
    { '[w', function() Snacks.words.jump(-vim.v.count1) end, desc = 'Previous reference' },
  },
}
