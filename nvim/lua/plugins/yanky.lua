return {
  'gbprod/yanky.nvim',
  event = 'VeryLazy',
  opts = {},
  keys = {
    { '<leader>p', function() Snacks.picker.yanky() end, desc = 'Paste from yank history' },
    { 'p', '<Plug>(YankyPutAfterCharwise)', mode = 'n' },
    { 'P', '<Plug>(YankyPutBeforeCharwise)', mode = 'n' },
    { 'gp', '<Plug>(YankyGPutAfterCharwise)', mode = 'n' },
    { 'gP', '<Plug>(YankyGPutBeforeCharwise)', mode = 'n' },
    { '[y', '<Plug>(YankyCycleForward)', mode = 'n' },
    { ']y', '<Plug>(YankyCycleBackward)', mode = 'n' },
  },
}
