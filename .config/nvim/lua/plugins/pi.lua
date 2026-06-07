return {
  {
    dir = "~/Documents/pi.nvim",
    name = "pi.nvim",
    cmd = { "PiAskSelection", "PiAsk", "PiCancel" },
    keys = {
      { "<leader>pe", "<cmd>PiAskSelection<cr>", mode = "v", desc = "pi: edit selection" },
      { "<leader>pa", "<cmd>PiAsk<cr>", desc = "pi: ask about buffer" },
      { "<leader>pc", "<cmd>PiCancel<cr>", desc = "pi: cancel" },
    },
  },
}
