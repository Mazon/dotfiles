-- colors/noir.lua
-- Custom minimal colorscheme: black bg, white fg, blue accents, gray for less important

-- Clear existing highlights
if vim.g.colors_name then
  vim.cmd('highlight clear')
  vim.cmd('syntax reset')
end
vim.opt.background = 'dark'
vim.g.colors_name = 'noir'

-- Palette
local bg        = '#000000'
local bg_float  = '#111111'
local bg_visual = '#1a1a2e'
local fg        = '#d4d4d4'
local fg_dim    = '#808080'
local fg_muted  = '#6b6b6b'
local fg_subtle = '#4a4a4a'
local blue      = '#7aa2f7'
local fg_bright = '#ffffff'

local red_diag     = '#cc4444'
local yellow_diag  = '#ccaa44'
local green_git    = '#4a8a4a'
local red_git      = '#8a4a4a'
local yellow_git   = '#8a8a4a'
local blue_dim     = '#3a3a5c'

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- ═══════════════════════════════════════════
-- Core / Syntax
-- ═══════════════════════════════════════════
hl('Normal',        { fg = fg,        bg = bg })
hl('NormalFloat',   { fg = fg,        bg = bg_float })
hl('NormalNC',      { fg = fg_dim,    bg = bg })
hl('Comment',       { fg = fg_muted,  italic = true })
hl('Constant',      { fg = fg })
hl('String',        { fg = '#b0b0b0' })
hl('Character',     { fg = '#b0b0b0' })
hl('Number',        { fg = fg })
hl('Boolean',       { fg = fg,        bold = true })
hl('Float',         { fg = fg })
hl('Identifier',    { fg = fg })
hl('Function',      { fg = blue })
hl('Statement',     { fg = fg,        bold = true })
hl('Conditional',   { fg = fg,        bold = true })
hl('Repeat',        { fg = fg,        bold = true })
hl('Label',         { fg = fg })
hl('Operator',      { fg = fg })
hl('Keyword',       { fg = fg,        bold = true })
hl('Exception',     { fg = fg,        bold = true })
hl('Include',       { fg = fg })
hl('Define',        { fg = fg })
hl('PreProc',       { fg = fg })
hl('Type',          { fg = '#b0b0b0', italic = true })
hl('StorageClass',  { fg = fg,        bold = true })
hl('Structure',     { fg = '#b0b0b0', italic = true })
hl('Typedef',       { fg = '#b0b0b0', italic = true })
hl('Special',       { fg = fg_dim })
hl('SpecialChar',   { fg = fg_dim })
hl('Tag',           { fg = blue })
hl('Delimiter',     { fg = fg_dim })
hl('SpecialComment',{ fg = fg_muted,  italic = true })
hl('Debug',         { fg = fg_dim })
hl('Underlined',    { fg = blue,      underline = true })
hl('Ignore',        { fg = fg_subtle })
hl('Error',         { fg = red_diag })
hl('Todo',          { fg = blue,      bold = true })
hl('qfLineNr',      { fg = fg_subtle })
hl('qfSeparator',   { fg = fg_subtle })
hl('Conceal',       { fg = fg_subtle })

-- ═══════════════════════════════════════════
-- Editor UI
-- ═══════════════════════════════════════════
hl('CursorLine',      { bg = bg_float })
hl('CursorLineNr',    { fg = fg_muted })
hl('LineNr',          { fg = fg_subtle })
hl('LineNrAbove',     { fg = '#3a3a3a' })
hl('LineNrBelow',     { fg = '#3a3a3a' })
hl('SignColumn',      { bg = 'NONE' })
hl('EndOfBuffer',     { fg = '#1a1a1a' })
hl('NonText',         { fg = '#1a1a1a' })
hl('Whitespace',      { fg = '#2a2a2a' })
hl('VertSplit',       { fg = '#2a2a2a' })
hl('WinSeparator',    { fg = '#2a2a2a' })
hl('Folded',          { fg = fg_muted,  bg = bg_float })
hl('FoldColumn',      { fg = fg_subtle, bg = 'NONE' })
hl('TabLine',         { fg = fg_muted,  bg = bg_float })
hl('TabLineFill',     { bg = bg })
hl('TabLineSel',      { fg = fg,        bold = true })
hl('Title',           { fg = fg,        bold = true })
hl('FloatBorder',     { fg = '#3a3a3a' })
hl('FloatTitle',      { fg = fg,        bold = true })
hl('Pmenu',           { fg = fg,        bg = bg_float })
hl('PmenuSel',        { fg = bg,        bg = blue })
hl('PmenuSbar',       { bg = '#2a2a2a' })
hl('PmenuThumb',      { bg = fg_subtle })
hl('PmenuMatch',      { fg = blue,      bg = bg_float })
hl('PmenuMatchSel',   { fg = bg,        bg = blue, bold = true })
hl('WildMenu',        { fg = bg,        bg = blue })
hl('Search',          { fg = bg,        bg = blue })
hl('IncSearch',       { fg = bg,        bg = blue, bold = true })
hl('CurSearch',       { fg = bg,        bg = blue, bold = true })
hl('Substitute',      { fg = bg,        bg = blue })
hl('Visual',          { bg = bg_visual })
hl('VisualNOS',       { bg = bg_visual })
hl('MatchParen',      { bg = bg_visual, bold = true })
hl('MatchWord',       { bg = bg_visual, underline = true })
hl('CursorColumn',    { bg = bg_float })
hl('ColorColumn',     { bg = '#0a0a0a' })
hl('QuickFixLine',    { bg = bg_float })
hl('StatusLine',      { fg = fg,        bg = bg_float })
hl('StatusLineNC',    { fg = fg_subtle, bg = bg })
hl('StatusLineTerm',  { fg = fg,        bg = bg_float })
hl('StatusLineTermNC',{ fg = fg_subtle, bg = bg })
hl('MsgArea',         { fg = fg })
hl('ModeMsg',         { fg = fg_muted })
hl('MoreMsg',         { fg = blue })
hl('Question',        { fg = blue })
hl('WarningMsg',      { fg = yellow_diag })
hl('ErrorMsg',        { fg = red_diag })
hl('Directory',       { fg = blue })
hl('SpecialKey',      { fg = fg_subtle })
hl('DiffAdd',         { fg = green_git,  bg = '#0a1a0a' })
hl('DiffChange',      { fg = yellow_git, bg = '#1a1a0a' })
hl('DiffDelete',      { fg = red_git,    bg = '#1a0a0a' })
hl('DiffText',        { fg = blue,       bg = '#0a0a1a' })
hl('Added',           { fg = green_git })
hl('Changed',         { fg = yellow_git })
hl('Removed',         { fg = red_git })

-- ═══════════════════════════════════════════
-- Diagnostics
-- ═══════════════════════════════════════════
hl('DiagnosticError',            { fg = red_diag })
hl('DiagnosticWarn',             { fg = yellow_diag })
hl('DiagnosticInfo',             { fg = blue })
hl('DiagnosticHint',             { fg = fg_muted })
hl('DiagnosticOk',               { fg = green_git })
hl('DiagnosticUnderlineError',   { fg = red_diag,    undercurl = true })
hl('DiagnosticUnderlineWarn',    { fg = yellow_diag, undercurl = true })
hl('DiagnosticUnderlineInfo',    { fg = blue,        undercurl = true })
hl('DiagnosticUnderlineHint',    { fg = fg_muted,    undercurl = true })
hl('DiagnosticVirtualTextError', { fg = '#5a2a2a' })
hl('DiagnosticVirtualTextWarn',  { fg = '#5a4a2a' })
hl('DiagnosticVirtualTextInfo',  { fg = '#2a2a5a' })
hl('DiagnosticVirtualTextHint',  { fg = '#3a3a3a' })
hl('DiagnosticSignError',        { fg = red_diag })
hl('DiagnosticSignWarn',         { fg = yellow_diag })
hl('DiagnosticSignInfo',         { fg = blue })
hl('DiagnosticSignHint',         { fg = fg_muted })

-- ═══════════════════════════════════════════
-- Git Signs (Gitsigns)
-- ═══════════════════════════════════════════
hl('GitSignsAdd',        { fg = green_git })
hl('GitSignsChange',     { fg = yellow_git })
hl('GitSignsDelete',     { fg = red_git })
hl('GitSignsAddLn',      { bg = '#0a1a0a' })
hl('GitSignsChangeLn',   { bg = '#1a1a0a' })
hl('GitSignsDeleteLn',   { bg = '#1a0a0a' })
hl('GitSignsAddInline',  { bg = '#0a2a0a' })
hl('GitSignsChangeInline',{ bg = '#2a2a0a' })
hl('GitSignsDeleteInline',{ bg = '#2a0a0a' })

-- ═══════════════════════════════════════════
-- Treesitter — @variable, @constant, @module
-- ═══════════════════════════════════════════
hl('@variable',             { fg = fg })
hl('@variable.builtin',     { fg = fg,        italic = true })
hl('@variable.parameter',   { fg = '#b0b0b0' })
hl('@variable.member',      { fg = fg })
hl('@constant',             { fg = fg })
hl('@constant.builtin',     { fg = fg,        bold = true })
hl('@constant.macro',       { fg = fg })
hl('@module',               { fg = '#b0b0b0', italic = true })
hl('@module.builtin',       { fg = '#b0b0b0', italic = true })
hl('@label',                { fg = fg_dim })

-- Treesitter — @string, @character
hl('@string',                   { fg = '#b0b0b0' })
hl('@string.documentation',     { fg = fg_muted })
hl('@string.regexp',            { fg = fg_dim })
hl('@string.escape',            { fg = fg_dim })
hl('@string.special',           { fg = fg_dim })
hl('@string.special.symbol',    { fg = fg_dim })
hl('@string.special.url',       { fg = blue, underline = true })
hl('@string.special.path',      { fg = fg_dim, underline = true })
hl('@string.json',              { fg = '#b0b0b0' })
hl('@character',                { fg = '#b0b0b0' })
hl('@character.special',        { fg = fg_dim })

-- Treesitter — @number, @boolean
hl('@boolean',       { fg = fg, bold = true })
hl('@number',        { fg = fg })
hl('@number.float',  { fg = fg })
hl('@float',         { fg = fg })
hl('@integer',       { fg = fg })

-- Treesitter — @type
hl('@type',              { fg = '#b0b0b0', italic = true })
hl('@type.builtin',      { fg = '#b0b0b0', italic = true })
hl('@type.definition',   { fg = '#b0b0b0', italic = true })
hl('@type.qualifier',    { fg = fg,        bold = true })

-- Treesitter — @attribute, @property
hl('@attribute', { fg = fg })
hl('@property',  { fg = fg })

-- Treesitter — @function
hl('@function',            { fg = blue })
hl('@function.builtin',    { fg = blue })
hl('@function.call',       { fg = blue })
hl('@function.macro',      { fg = blue })
hl('@function.method',     { fg = blue })
hl('@function.method.call',{ fg = blue })
hl('@constructor',         { fg = blue })

-- Treesitter — @operator
hl('@operator', { fg = fg })

-- Treesitter — @keyword
hl('@keyword',                       { fg = fg, bold = true })
hl('@keyword.coroutine',             { fg = fg, bold = true })
hl('@keyword.function',              { fg = blue })
hl('@keyword.operator',              { fg = fg, bold = true })
hl('@keyword.import',                { fg = fg })
hl('@keyword.type',                  { fg = fg, bold = true })
hl('@keyword.modifier',              { fg = fg, bold = true })
hl('@keyword.repeat',                { fg = fg, bold = true })
hl('@keyword.return',                { fg = fg, bold = true })
hl('@keyword.debug',                 { fg = fg_dim })
hl('@keyword.exception',             { fg = fg, bold = true })
hl('@keyword.conditional',           { fg = fg, bold = true })
hl('@keyword.conditional.ternary',   { fg = fg })
hl('@keyword.directive',             { fg = fg })
hl('@keyword.directive.define',      { fg = fg })
hl('@keyword.storage',               { fg = fg, bold = true })

-- Treesitter — @punctuation
hl('@punctuation.delimiter', { fg = fg_dim })
hl('@punctuation.bracket',   { fg = fg_dim })
hl('@punctuation.special',   { fg = fg_dim })

-- Treesitter — @comment
hl('@comment',               { fg = fg_muted, italic = true })
hl('@comment.documentation', { fg = fg_muted, italic = true })
hl('@comment.error',         { fg = red_diag, italic = true })
hl('@comment.warning',       { fg = yellow_diag, italic = true })
hl('@comment.todo',          { fg = blue, italic = true })
hl('@comment.note',          { fg = fg_muted, italic = true })

-- Treesitter — @tag (HTML/XML/JSX)
hl('@tag',              { fg = blue })
hl('@tag.attribute',    { fg = fg })
hl('@tag.delimiter',    { fg = fg_dim })
hl('@tag.javascript',   { fg = blue })

-- Treesitter — @markup
hl('@markup.heading',         { fg = fg,        bold = true })
hl('@markup.strong',          { fg = fg,        bold = true })
hl('@markup.italic',          { fg = fg,        italic = true })
hl('@markup.strikethrough',   { fg = fg_muted,  strikethrough = true })
hl('@markup.underline',       { fg = fg,        underline = true })
hl('@markup.link',            { fg = blue,      underline = true })
hl('@markup.link.label',      { fg = blue })
hl('@markup.link.url',        { fg = blue,      underline = true })
hl('@markup.list',            { fg = fg_dim })
hl('@markup.list.checked',    { fg = green_git })
hl('@markup.list.unchecked',  { fg = fg_muted })
hl('@markup.raw',             { fg = '#b0b0b0' })
hl('@markup.raw.block',       { fg = '#b0b0b0' })
hl('@diff.plus',              { fg = green_git })
hl('@diff.minus',             { fg = red_git })
hl('@diff.delta',             { fg = yellow_git })

-- ═══════════════════════════════════════════
-- LSP Semantic Tokens
-- ═══════════════════════════════════════════
hl('@lsp.type.class',          { fg = '#b0b0b0', italic = true })
hl('@lsp.type.decorator',      { fg = fg })
hl('@lsp.type.enum',           { fg = '#b0b0b0', italic = true })
hl('@lsp.type.enumMember',     { fg = fg })
hl('@lsp.type.function',       { fg = blue })
hl('@lsp.type.interface',      { fg = '#b0b0b0', italic = true })
hl('@lsp.type.macro',          { fg = blue })
hl('@lsp.type.method',         { fg = blue })
hl('@lsp.type.namespace',      { fg = '#b0b0b0', italic = true })
hl('@lsp.type.parameter',      { fg = '#b0b0b0' })
hl('@lsp.type.property',       { fg = fg })
hl('@lsp.type.struct',         { fg = '#b0b0b0', italic = true })
hl('@lsp.type.type',           { fg = '#b0b0b0', italic = true })
hl('@lsp.type.typeParameter',  { fg = '#b0b0b0', italic = true })
hl('@lsp.type.variable',       { fg = fg })
hl('@lsp.mod.readonly',        { link = '@constant' })
hl('@lsp.mod.deprecated',      { fg = fg_muted, strikethrough = true })

-- ═══════════════════════════════════════════
-- Plugin: Snacks.nvim (Picker)
-- ═══════════════════════════════════════════
hl('SnacksPickerDir',    { fg = fg_muted })
hl('SnacksPickerMatch',  { fg = blue })
hl('SnacksPickerSel',    { fg = fg,   bg = bg_visual })
hl('SnacksPickerInput',  { fg = fg })

-- ═══════════════════════════════════════════
-- Plugin: Snacks.nvim (Words)
-- ═══════════════════════════════════════════
hl('SnacksWords',     { bg = bg_visual })

-- ═══════════════════════════════════════════
-- Plugin: Blink.cmp
-- ═══════════════════════════════════════════
hl('BlinkCmpLabel',      { fg = fg })
hl('BlinkCmpLabelMatch', { fg = blue })
hl('BlinkCmpKind',       { fg = fg_muted })
hl('BlinkCmpDoc',        { fg = fg,   bg = bg_float })
hl('BlinkCmpDocBorder',  { fg = '#3a3a3a' })
hl('BlinkCmpGhostText',  { fg = '#3a3a3a' })

-- ═══════════════════════════════════════════
-- Plugin: Flash
-- ═══════════════════════════════════════════
hl('FlashLabel',     { fg = bg,   bg = blue,     bold = true })
hl('FlashMatch',     { bg = bg_visual })
hl('FlashCurrent',   { bg = bg_visual, bold = true })
hl('FlashBackdrop',  { fg = fg_subtle })
hl('FlashPrompt',    { fg = fg })

-- ═══════════════════════════════════════════
-- Plugin: Which-key
-- ═══════════════════════════════════════════
hl('WhichKeyNormal',   { link = 'NormalFloat' })
hl('WhichKey',         { fg = fg_muted })
hl('WhichKeyDesc',     { fg = fg })
hl('WhichKeyGroup',    { fg = blue })
hl('WhichKeySeparator',{ fg = fg_subtle })
hl('WhichKeyValue',    { fg = fg_muted })

-- ═══════════════════════════════════════════
-- Plugin: Mini.nvim (Icons)
-- ═══════════════════════════════════════════
hl('MiniIconsAzure',  { fg = blue })
hl('MiniIconsBlue',   { fg = blue })
hl('MiniIconsCyan',   { fg = fg_dim })
hl('MiniIconsGreen',  { fg = green_git })
hl('MiniIconsGrey',   { fg = fg_muted })
hl('MiniIconsOrange', { fg = yellow_git })
hl('MiniIconsPurple', { fg = fg_dim })
hl('MiniIconsRed',    { fg = red_git })
hl('MiniIconsYellow', { fg = yellow_git })

-- ═══════════════════════════════════════════
-- Plugin: Neogit
-- ═══════════════════════════════════════════
hl('NeogitBranch',               { fg = blue })
hl('NeogitRemote',               { fg = blue })
hl('NeogitHunkHeader',           { bg = bg_float })
hl('NeogitHunkHeaderHighlight',  { bg = bg_visual })
