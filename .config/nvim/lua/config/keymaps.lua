-- Function helpers
local Utils = require('config.utils')

-- Better up/down
vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Search and replace word under the cursor
vim.keymap.set('n', '<leader>R', ':%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>')

-- Search and replace in visual selection
vim.keymap.set('x', '<leader>/', [[:s/\%V]])

-- For correcting a word in insert mode
vim.keymap.set('i', '<c-l>', '<c-g>u<Esc>[s1z=`]a<c-g>u')

-- Buffers
vim.keymap.set('n', '<leader>bd', '<cmd>bd<cr>', { desc = 'Delete Buffer' })

-- Indent lines in visual selection
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Nicer Paste 
vim.keymap.set('v', 'p', '"_dP')
vim.keymap.set('x', 'p', 'P')
vim.keymap.set('n', 'dD', '"_dd')

-- Not yanking with 'c' and 'x'
vim.keymap.set({ 'n', 'v' }, 'c', '"_c')
vim.keymap.set('n', 'C', '"_C')

-- Add blank line without leaving normal mode
vim.keymap.set('n', '<leader>o', 'o<Esc>')
vim.keymap.set('n', '<leader>O', 'O<Esc>')

-- Clear search with <esc>
vim.keymap.set({ 'i', 'n' }, '<esc>', '<cmd>noh<cr><esc>', { desc = 'Escape and clear hlsearch' })

-- Indent properly when entering insert mode on empty lines
vim.keymap.set('n', 'i', function()
    if vim.api.nvim_get_current_line():find('^%s*$') then
        return [["_cc]]
    end
    return 'i'
end, { expr = true, desc = 'better i' })

-- Plugins

-- Nvim-dap
vim.keymap.set(
    'n',
    '<leader>dB',
    '<cmd>lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>',
    { desc = 'Add Conditional Breakpoint' }
)
vim.keymap.set('n', '<leader>dc', '<cmd>DapContinue<CR>', { desc = 'Dap Continue' })
vim.keymap.set('n', '<leader>dsi', '<cmd>DapStepInto<CR>', { desc = 'Dap Step Into' })
vim.keymap.set('n', '<leader>dso', '<cmd>DapStepOver<CR>', { desc = 'Dap Step Over' })
vim.keymap.set('n', '<leader>dst', '<cmd>DapStepOut<CR>', { desc = 'Dap Step Out' })
vim.keymap.set('n', '<leader>dt', '<cmd>DapTerminate<CR>', { desc = 'Dap Terminate' })
vim.keymap.set('n', '<leader>dl', '<cmd>DapShowLog<CR>', { desc = 'Dap Show Log' })
vim.keymap.set('n', '<leader>dr', '<cmd>DapToggleRepl<CR>', { desc = 'Dap Toggle Repl' })

-- Diffview
vim.keymap.set('n', '<leader>dv', function()
    if vim.bo.ft == 'DiffviewFiles' then
        vim.cmd('DiffviewClose')
    else
        vim.cmd('DiffviewOpen')
    end
end, { desc = 'Toggle Diffview' })


-- Trouble
vim.keymap.set(
    'n',
    '<leader>xw',
    '<cmd>TroubleToggle lsp_workleader_diagnostics<cr>',
    { desc = 'Trouble Workleader Diagnostics' }
)
vim.keymap.set(
    'n',
    '<leader>xd',
    '<cmd>TroubleToggle lsp_document_diagnostics<cr>',
    { desc = 'Trouble Document Diagnostics' }
)
vim.keymap.set('n', '<leader>xl', '<cmd>TroubleToggle loclist<cr>', { desc = 'Trouble Location List' })
vim.keymap.set('n', '<leader>xq', '<cmd>TroubleToggle quickfix<cr>', { desc = 'Trouble Quickfix' })

-- Scroll
vim.keymap.set('n', 'zz', "<Cmd>lua Scroll('zz', 0, 1)<CR>")
vim.keymap.set('n', 'zt', "<Cmd>lua Scroll('zt', 0, 1)<CR>")
vim.keymap.set('n', 'zb', "<Cmd>lua Scroll('zb', 0, 1)<CR>")

-- Telescope
vim.keymap.set('n', '<leader>b', '<cmd>Telescope buffers<cr>',{desc = 'Find Buffers'})
vim.keymap.set('n', '<leader>f', '<cmd>Telescope find_files<cr>',{ desc = 'Find Files'})
vim.keymap.set('n', '<leader>t', '<cmd>Telescope live_grep<cr>',{desc = 'Find Word'})
--vim.keymap.set('n', '<leader>fG', '<cmd>Telescope grep_string<cr>',{ desc = 'Find Word Under Cursor'})
--vim.keymap.set('n', '<leader>fG', '<cmd>Telescope git_files<cr>',{ desc = 'Find Git Files'})


-- Projects
vim.keymap.set('n', '<leader>p', '<cmd>Telescope projects<cr>', {desc = 'Projects'})
