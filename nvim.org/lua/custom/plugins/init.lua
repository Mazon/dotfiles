-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'Exafunction/codeium.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
    },
    config = function()
      require('codeium').setup {}
    end,
  },
  --  {
  --    --'~whynothugo/lsp_lines.nvim',
  --    'ErichDonGubler/lsp_lines.nvim',
  --    config = function()
  --      require('lsp_lines').setup()
  --    end,
  --  },
  --  },
  --  {
  --    'mrcjkb/rustaceanvim',
  --    version = '^5', -- Recommended
  --    lazy = false, -- This plugin is already lazy
  --  },
}
