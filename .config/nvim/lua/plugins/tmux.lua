return {
  'christoomey/vim-tmux-navigator',
  cond = function()
    return os.getenv 'TMUX' ~= nil
  end,
}
